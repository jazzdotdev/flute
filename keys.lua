
-- https://tools.ietf.org/id/draft-cavage-http-signatures-08.html

local keys = {}

function keys.verify_http_signature (message)

  -- TODO: The headers part of the signature header is being ignored.
  -- every header listed in headers, separated with spaces, must be included
  -- in the signature string. Also the algorithm field is ignored as well, this
  -- should fail if algorithm is not ed25519, also fields can be given in any
  -- order, not specifically keyId before signature

  local header = message.headers["signature"]
  log.trace("signature header", header)

  if not header then log.info("Unsigned Request") return end

  local keyId, signature = header:match('keyId="([^"]+)".+signature="([^"]+)"')
  log.debug("keyId", keyId)
  log.debug("signature", signature)

  local pub_key = content.iter_files(keyId,
    function (file_uuid, header, body)
      if header.type == "key" and header.kind == "sign_public" then
        return body
      end
    end
  )

  if not pub_key then
    log.info("no public key found for profile " .. keyId)
    return false
  end

  pub_key = crypto.sign.load_public(pub_key)

  log.trace("public key", pub_key)

  local signature_string = "date: " .. message.headers.date .. "\n" .. message.body_raw
  log.trace("signature string", signature_string)

  local is_valid = pub_key:verify_detached(signature_string, signature)
  return is_valid
end

function keys.sign_http_message (message)
  local profile_uuid = content.iter_files("home",
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

  local priv_key = content.iter_files("home",
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

return keys
