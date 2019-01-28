function keys.verify_http_signature (message)

  -- TODO: The headers part of the signature header is being ignored.
  -- every header listed in headers, separated with spaces, must be included
  -- in the signature string. Also the algorithm field is ignored as well, this
  -- should fail if algorithm is not ed25519, also fields can be given in any
  -- order, not specifically keyId before signature

  local header = message.headers["signature"]
  if not header then
    log.info("No signature header")
    return false
  end
  log.trace("signature header " .. header)

  if not header then log.info("Unsigned Request") return end

  local keyId, signature = header:match('keyId="([^"]+)".+signature="([^"]+)"')
  log.debug("keyId " .. keyId)
  log.debug("signature" .. signature)

  local pub_key = content.walk_documents(keyId,
    function (file_uuid, header, body)
      if header.model == "key" and header.kind == "sign_public" then
      return body
      end
    end
  )

  if not pub_key then
    log.info("no public key found for profile " .. keyId)
    return false
  end

  pub_key = crypto.sign.load_public(pub_key)

  log.trace("public key " .. tostring(pub_key))

  local signature_string = "date: " .. message.headers.date .. "\n" .. message.body_raw
  log.trace("signature string " .. signature_string)

  local is_valid = pub_key:verify_detached(signature_string, signature)

  if is_valid then
    message.profile_uuid = keyId
  end
  
  return is_valid
end