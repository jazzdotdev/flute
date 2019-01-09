function contentdb.split_header (document_text)
  log.trace("Running: " .. debug.getinfo(1, 'S').source)
  local scl_text, body = document_text:match("---\n(.*)\n+...\n(.*)")
  if scl_text == nil then
    scl_text = ""
  end
  local header = scl.to_table(scl_text)
  return header, body
end
