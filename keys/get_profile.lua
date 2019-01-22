function keys.get_profile (profile)
  return content.walk_documents(profile or content.home,
    function (file_uuid, header, body)
      if header.model == "profile" then
        return file_uuid, header.name
      end
    end
  )
end