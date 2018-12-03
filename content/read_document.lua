function content.read_document (in_uuid)
  return content.walk_documents(nil, function (file_uuid, header, body, profile)
    if file_uuid == in_uuid then
      return header, body, profile
    end
  end)
end