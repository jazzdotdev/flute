function keys.get_profile_data ()

  local data = {}
  local uuid, name = keys.get_profile()
  log.debug("UUID: " .. tostring(uuid))

  data.sign_public_key = contentdb.walk_documents(uuid,
    function (file_uuid, header, body)
      if header.model == "key"
      and header.kind == "sign_private"
      then return body end
    end
  )

  data.place = contentdb.walk_documents(uuid,
    function (file_uuid, header, body)
      if header.model == "place" then
        return header.host
      end
    end
  )

  return data
end