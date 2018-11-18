
local content = {
  stores = {
    home = "content/home/"
  }
}

fs.create_dir("content/home", true)

function content.split_header (document_text)
    local yaml_text, body = document_text:match("(.-)\n%.%.%.*\n?(.*)")
    local header = yaml.to_table(yaml_text)
    return header, body
end

local valua = require "third-party.valua"


-- Methods for the model class
local model_metatable = {}
model_metatable.__index = model_metatable
function model_metatable:validate (object)
  for name, validator in pairs(self.fields) do
    local result, err = validator(object[name])
    if not result then
      return result, name .. ": " .. err
    end
  end
  return true
end

function content.get_model_definition (name)
  local content = fs.read_file("models/" .. name .. ".yaml")
  if not content then
    return nil, "model " .. name .. " not found"
  end
  return yaml.to_table(content)
end

function content.get_validator (name)
  local model_def, err = content.get_model_definition(name)
  if not model_def then return nil, err end

  for name, field_def in pairs(model_def.fields) do
    local validator = valua:new()

    if field_def.optional then
      validator.optional(true)
    end

    if field_def.type == "number" then
      validator.number()
    elseif field_def.type == "integer" then
      validator.integer()
    elseif field_def.type == "string" then
      validator.string()
    else
      return nil, "missing type in field " .. name
    end

    fields[name] = validator
  end

  local model = setmetatable({
    fields = fields
  }, model_metatable)

  return model
end

function content.validate_document (header)
  if not header.model then
    return false, "document does not define a model"
  end
  local model, err = content.get_validator(header.model)
  if not model then
    return false, err
  end

  return model:validate(header)
end

-- Returns the path of the given document. A document can be found without
-- giving the store it's in, but it's a lot slower because all store
-- directories have to be searched
function content.get_document_path (doc_uuid, store_id)
  if store_id then
    return (content.stores[store_id] or "content/" .. store_id) .. doc_uuid
  else
    for store_id, dir in content.stores_iter() do

    end
  end
end

function content.read_document (doc_id, store_id)

  -- If not given, find the store of the document using tantivy
  if not store_id then
    -- + means required
    -- uuids have dashes, which are special characters so they have to be quoted
    local result = content.query('+uuid:"' .. doc_id .. '"')
    if #result == 0 then
      error("Document " .. doc_id .. " not found in index")
    end

    store_id = result[1]:get_first(content.fields.store)
  end

  local path = content.stores[store_id] .. doc_id

  local file_content = fs.read_file(path)
  if not file_content then
    error("could not open " .. path)
  end

  local fields, body = content.split_header(file_content)

  return fields, body, store_id
end

function content.documents (store_id)
  -- TODO: properly test this function

  local query = "*"
  if store_id then
    -- "store:" says to look directly in the store field
    -- + means it's required
    -- store_id can have dashes, so it needs to be quoted
    query = '+store:"' .. store_id .. '"'
  end

  -- Coroutines are like "threads"
  local docs_co = coroutine.create(function ()
    local result = content.query(query)

    for i = 1, #result do
      local doc = result[i]

      -- each time it reaches this, the coroutine is paused until
      -- called again and returns the values given to yield
      coroutine.yield(
        doc:get_first(content.fields.uuid),
        doc:get_first(content.fields.store)
      )
    end
  end)

  -- This is an iterator, so it returns an iterator function
  -- (each time it's called, returns the next item)
  return function ()
    local cont, uuid, store_id = coroutine.resume(docs_co)
    if cont then
      return uuid, store_id
    end
  end
end

-- DEPRECATED
function content.walk_documents (_store_id, fn)
  for doc_id, store_id in content.documents(_store_id) do

    local path = content.stores[store_id] .. doc_id
    local file_content = fs.read_file(path)
    if not file_content then
      log.error("could not open " .. path)
    end

    local header, body = content.split_header(file_content)

    -- If the fn applied on this file returns values, stop walking
    local results = { fn(doc_id, header, body, store_id) }
    if results[1] then
      return table.unpack(results)
    end
  end
end

function content.write_file (store_id, file_uuid, fields, body_param)
  local dir = content.stores[store_id]
  if not dir then
    dir = "content/" .. store_id .. "/"
    fs.create_dir(dir, true)
    content.stores[store_id] = dir
  end
  local path = dir .. file_uuid

  if not fields.creation_time then
    fields.creation_time = tostring(time.now())
  end
  
  local body = yaml.from_table(fields) .. "\n...\n" .. (body_param or "")
  local file = io.open(path, "w")
  if not file then
    log.error("Could not open file", path)
  end
  file:write(body)
  file:close()

  events["document_created"]:trigger({
    store_id = store_id,
    file_uuid = file_uuid,
    fields = header,
    body = body
  })
end

-- Add all directories in content to the stores table
for entry in fs.entries("content/") do
  if fs.metadata("content/" .. entry).type == "directory" then
    content.stores[entry] = "content/" .. entry .. "/"
  end
end


-----------------------------------
--------      Tantivy      --------
-----------------------------------

function content.setup_schema ()
  local builder = tan.new_schema_builder()

  builder:add_text_field("uuid", {tan.STRING, tan.STORED})
  builder:add_text_field("store", {tan.STRING, tan.STORED})
  builder:add_text_field("model", {tan.STRING, tan.STORED})
  builder:add_text_field("content", {tan.TEXT})

  content.schema = builder:build()

  content.fields = {
    uuid = content.schema:get_field("uuid"),
    store = content.schema:get_field("store"),
    model = content.schema:get_field("model"),
    content = content.schema:get_field("content"),
  }
end

function content.setup_index (path)
  path = path or "./tantivy-index"

  --TODO: implement fs.remove_dir(path, true)
  os.execute("rm -r " .. path)
  fs.create_dir(path, true)

  content.index = tan.index_in_dir(path, content.schema)

  local index_writer = content.index:writer(50000000)

  function add_document (doc_id, store_id)

    -- Would use content.read_document but it doesn't return the file contents
    local path = content.stores[store_id] .. doc_id

    local file_content = fs.read_file(path)
    if not file_content then
      error("could not open " .. path)
    end

    local doc_fields = content.split_header(file_content)

    if doc_fields.model then
      local doc = tan.new_document()
      doc:add_text(content.fields.uuid, doc_id)
      doc:add_text(content.fields.store, store_id)
      doc:add_text(content.fields.model, doc_fields.model)
      doc:add_text(content.fields.content, file_content)
      index_writer:add_document(doc)
    else
      log.warn("Document " .. doc_id .. " in " .. store_id .. " does not have a model")
    end
  end


  -- Walk through all documents and add them to the index
  for store_id, dir in pairs(content.stores) do
    if fs.exists(dir) then
      for doc_id in fs.entries(dir) do
        add_document(doc_id, store_id)
      end
    end
  end

  index_writer:commit()
  content.index:load_searchers()
end

function content.query (query_str)
  log.trace("Start tantivy search")

  local fields = {}
  for _, v in pairs(content.fields) do
    table.insert(fields, v)
  end

  local parser = tan.query_parser_for_index(content.index, fields)
  local coll = tan.top_collector_with_limit(10)
  local result = content.index:search(parser, query_str, coll)

  return result
  --[[
    for i = 1, #result do
      local doc = result[i]
      table.insert(uuids, {
        file = doc:get_first(uuid_field),
        profile = "unknown_profile"
      })
    end
    log.trace("End tantivy search")
  --]]
end


return content