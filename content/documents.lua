function content.documents (query)
  local query = query or "*"

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