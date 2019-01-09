function contentdb.add_document_to_index (doc_id, store_id, file_content, model)
  if not model then
  log.warn("Document " .. doc_id .. " in " .. store_id .. " does not have a model")
  return
  end

  local doc = tan.new_document()
  doc:add_text(contentdb.fields.uuid, doc_id)
  doc:add_text(contentdb.fields.store, store_id)
  doc:add_text(contentdb.fields.model, model)
  doc:add_text(contentdb.fields.content, file_content)
  contentdb.index_writer:add_document(doc)
end