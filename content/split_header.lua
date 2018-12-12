function content.split_header (document_text)
  local scl_text, body = document_text:match("---\n(.*)\n...")
  local header = scl.to_table(scl_text)
  return header, body
end
