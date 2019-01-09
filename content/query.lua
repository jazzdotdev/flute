function contentdb.query (query_str)
  log.trace("Start tantivy search")

  local fields = {}
  for _, v in pairs(contentdb.fields) do
  table.insert(fields, v)
  end

  local parser = tan.query_parser_for_index(contentdb.index, fields)
  local coll = tan.top_collector_with_limit(500)
  local result = contentdb.index:search(parser, query_str, coll)

  return result
  --[[
  for i = 1, #result do
    local doc = result[i]
    table.insert(uuids, {
    file = doc:get_first(uuid_field),
    profile = "unknown_profile"
    })
  end
  log.trace("End tantivy search")
  --]]
end