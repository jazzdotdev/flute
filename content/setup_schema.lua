function contentdb.setup_schema ()
  local builder = tan.new_schema_builder()

  builder:add_text_field("uuid", {tan.STRING, tan.STORED})
  builder:add_text_field("store", {tan.STRING, tan.STORED})
  builder:add_text_field("model", {tan.STRING, tan.STORED})
  builder:add_text_field("contentdb", {tan.TEXT})

  contentdb.schema = builder:build()

  contentdb.fields = {
  uuid = contentdb.schema:get_field("uuid"),
  store = contentdb.schema:get_field("store"),
  model = contentdb.schema:get_field("model"),
  contentdb = contentdb.schema:get_field("contentdb"),
  }
end
