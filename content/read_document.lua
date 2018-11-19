
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