function content.setup_schema ()
  local builder = tan.new_schema_builder()

  builder:add_text_field("uuid", {tan.STRING, tan.STORED})
  builder:add_text_field("store", {tan.STRING, tan.STORED})
  builder:add_text_field("model", {tan.STRING, tan.STORED})
  builder:add_text_field("content", {tan.TEXT})

  content.schema = builder:build()

  content.fields = {
  uuid = content.schema:get_field("uuid"),
  store = content.schema:get_field("store"),
  model = content.schema:get_field("model"),
  content = content.schema:get_field("content"),
  }
end
