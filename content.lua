
local content = {
  stores = {}
}

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

function content.read_document (in_uuid)
  return content.walk_documents(nil, function (file_uuid, header, body, profile)
    if file_uuid == in_uuid then
      return header, body, profile
    end
  end)
end

function content.documents (store_id)
  if store_id then
    local dir = content.stores[store_id]

    local f = fs.entries(dir)

    return function ()
      local entry = f()
      if entry then
        return entry, store_id
      end
    end
  else

    local docs_co = coroutine.create(function ()
      for store_id, dir in pairs(content.stores) do
        for entry in fs.entries(dir) do
          coroutine.yield(entry, store_id)
        end
      end
    end)

    return function ()
      local cont, uuid, store_id = coroutine.resume(docs_co)
      if cont then
        return uuid, store_id
      end
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

function content.write_file (store_id, file_uuid, header, body)
  local dir = content.stores[store_id]
  if not dir then
    dir = "content/" .. store_id .. "/"
    fs.create_dir(dir, true)
    content.stores[store_id] = dir
  end
  local path = dir .. file_uuid
  local body = yaml.from_table(header) .. "\n...\n" .. (body or "")
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

function content.read_log (log_uuid)
  -- It's getting just the request logs, it should read all logs but this
  -- function is not completely thought trough yet
  local dir = "log/incoming-request/"

  for _, file_uuid in ipairs(fs.get_all_files_in(dir)) do
    local path = dir .. file_uuid
    local file_content = fs.read_file(path)
    if not file_content then
      error("could not open " .. path)
    end

    return yaml.to_table(file_content)
  end
end

-- Add all directories in content to the stores table
for entry in fs.entries("content/") do
  if fs.metadata("content/" .. entry).type == "directory" then
    content.stores[entry] = "content/" .. entry .. "/"
  end
end

return content