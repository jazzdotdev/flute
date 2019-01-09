function contentdb.documents (store_id)
  if store_id then
    local dir = contentdb.stores[store_id]
  
    local f = fs.entries(dir)
  
    return function ()
    local entry = f()
    if entry then
      return entry, store_id
    end
    end
  else
  
    local docs_co = coroutine.create(function ()
    for store_id, dir in pairs(contentdb.stores) do
      if fs.exists(dir) then
      for entry in fs.entries(dir) do
        coroutine.yield(entry, store_id)
      end
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