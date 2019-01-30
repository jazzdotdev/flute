function keys.get_private_key ()
  local priv_key = contentdb.walk_documents(contentdb.home,
    function (file_uuid, header, body)
      if header.model == "key"
        and header.kind == "sign_private"
        then
        return body
      end
    end
  )
  
  if priv_key then
    return crypto.sign.load_secret(priv_key)
  end
end