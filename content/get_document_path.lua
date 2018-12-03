function content.get_document_path (doc_uuid, store_id)
  if store_id then
    return (content.stores[store_id] or "content/" .. store_id) .. doc_uuid
  else
    for store_id, dir in content.stores_iter() do
  
    end
  end
end