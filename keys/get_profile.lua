function keys.get_profile (profile)
  return contentdb.walk_documents(profile or contentdb.home,
    function (file_uuid, header, body)
      if header.model == "profile" then
        return file_uuid, header.name
      end
    end
  )
end