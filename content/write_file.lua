function content.write_file (store_id, file_uuid, fields, body)
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
  
  local file_content = yaml.from_table(fields) .. "\n...\n" .. (body or "")
  local file = io.open(path, "w")
  if not file then
    log.error("Could not open file", path)
  end
  file:write(file_content)
  file:close()

  -- Write the document into tantivy's index
  content.add_document_to_index(
    file_uuid,
    store_id,
    file_content,
    fields.model
  )
  content.index_writer:commit()
  content.index:load_searchers()


  events["document_created"]:trigger({
    store_id = store_id,
    file_uuid = file_uuid,
    fields = header,
    body = body
  })
end