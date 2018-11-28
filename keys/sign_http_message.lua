function keys.sign_http_message (message)
    local profile_uuid = content.walk_documents("home",
      function (file_uuid, header, body)
        if header.type == "profile" then
          return file_uuid
        end
      end
    )
  
    if not profile_uuid then
      log.error("Could not sign: No home profile found")
      return false
    end
  
    local priv_key = content.walk_documents("home",
      function (file_uuid, header, body)
        if header.type == "key"
        and header.kind == "sign_private"
        then
          return body
        end
      end
    )
  
    if not priv_key then
      log.error("Could not sign: No private key for home profile")
      return false
    end
  
    priv_key = crypto.sign.load_secret(priv_key)
  
    if not message.headers.date then
      message.headers.date = tostring(time.now())
    end
  
    -- Fails if body is not a string
    local signature_string = "date: " .. message.headers.date .. "\n" .. message.body
  
    local signature = priv_key:sign_detached(signature_string)
  
    message.headers.signature = 'keyId="' .. profile_uuid .. '",algorithm="ed25519",signature="' .. signature .. '"'
  
    return message
  end