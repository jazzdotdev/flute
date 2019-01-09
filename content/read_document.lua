function contentdb.read_document (in_uuid)
  log.trace("Running: " .. debug.getinfo(1, 'S').source)
  return contentdb.walk_documents(nil, function (file_uuid, header, body, profile)
    if file_uuid == in_uuid then
      return header, body, profile
    end
  end)
end
