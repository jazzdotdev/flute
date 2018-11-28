function content.setup_index (path)
  path = path or "./tantivy-index"

  --TODO: implement fs.remove_dir(path, true)
  --os.execute("rm -r " .. path)
  --fs.create_dir(path, true)

  content.index = tan.index_in_ram(content.schema)

  content.index_writer = content.index:writer(50000000)


  -- Walk through all documents and add them to the index
  for store_id, dir in pairs(content.stores) do
    if fs.exists(dir) then
      for doc_id in fs.entries(dir) do


        -- Would use content.read_document but it doesn't return the file contents
        local path = content.stores[store_id] .. doc_id

        local file_content = fs.read_file(path)
        if not file_content then
          error("could not open " .. path)
        end

        local doc_fields = content.split_header(file_content)

        content.add_document_to_index(
          doc_id,
          store_id,
          file_content,
          doc_fields.model
        )
      end
    end
  end

  content.index_writer:commit()
  content.index:load_searchers()
end