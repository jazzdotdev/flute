function keys.get_private_key ()
    local priv_key = content.walk_documents("home",
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