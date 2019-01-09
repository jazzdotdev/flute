function contentdb.get_document_path (doc_uuid, store_id)
  if store_id then
    return (contentdb.stores[store_id] or "contentdb/" .. store_id) .. doc_uuid
  else
    for store_id, dir in contentdb.stores_iter() do
  
    end
  end
end