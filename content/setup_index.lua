function contentdb.setup_index (path)
  path = path or "./tantivy-index"

  --TODO: implement fs.remove_dir(path, true)
  --os.execute("rm -r " .. path)
  --fs.create_dir(path, true)

  contentdb.index = tan.index_in_ram(contentdb.schema)

  contentdb.index_writer = contentdb.index:writer(50000000)

  -- Walk through all documents and add them to the index
  for store_id, dir in pairs(contentdb.stores) do
  if fs.exists(dir) then
    for doc_id in fs.entries(dir) do

      -- Would use contentdb.read_document but it doesn't return the file contentdbs
      local path = contentdb.stores[store_id] .. doc_id

      local file_content = fs.read_file(path)
      if not file_content then
        error("could not open " .. path)
      end

      local doc_fields = contentdb.split_header(file_content)

      contentdb.add_document_to_index(
        doc_id,
        store_id,
        file_content,
        doc_fields.model
      )
      end
    end
  end

  contentdb.index_writer:commit()
  contentdb.index:load_searchers()
end