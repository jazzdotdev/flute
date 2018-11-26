
-- https://tools.ietf.org/id/draft-cavage-http-signatures-08.html

local keys = {}

function get_profile ()
  return content.walk_documents("home",
    function (file_uuid, header, body)
      if header.model == "profile" then
        return file_uuid, header.name
      end
    end
  )
end

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

  log.trace("public key", pub_key)

  local signature_string = "date: " .. message.headers.date .. "\n" .. message.body_raw
  log.trace("signature string", signature_string)

  local is_valid = pub_key:verify_detached(signature_string, signature)

  if is_valid then
    message.profile_uuid = keyId
  end
  
  return is_valid
end

function keys.sign_http_message (message)
  local profile_uuid = get_profile()

  if not profile_uuid then
    return false, "No home profile found"
  end

  local priv_key = keys.get_private_key()

  if not priv_key then
    return false, "No private key for home profile"
  end

  if not message.headers.date then
    message.headers.date = tostring(time.now())
  end

  -- Fails if body is not a string
  local signature_string = "date: " .. message.headers.date .. "\n" .. message.body

  local signature = priv_key:sign_detached(signature_string)

  message.headers.signature = 'keyId="' .. profile_uuid .. '",algorithm="ed25519",signature="' .. signature .. '"'

  return message
end

function keys.witness_document (document_id)
  local date = tostring(time.now())

  local profile_uuid = get_profile()
  if not profile_uuid then return nil, "Profile not found" end

  local fields, body, store = content.read_document(document_id)
  if not fields then return nil, "Document not found" end

  local priv_key = keys.get_private_key()
  if not priv_key then return nil, "Private key not found" end

  local field_str = ""
  for k, v in table.sorted_pairs(fields) do
    field_str = field_str .. tostring(k) .. "=" .. tostring(v) .. ";"
  end

  local sign_str = date .. ";" .. field_str .. body

  local signature = priv_key:sign_detached(sign_str)

  local witness_id = uuid.v4()

  local witness_fields = {
    model = "witness",
    profile = profile_uuid,
    document = document_id,
    document_model = fields.model,
    [fields.model] = document_id,
    date = date,
    signed_string = sign_str,
    signature = signature
  }

  content.write_file("home", witness_id, witness_fields, "")

  return witness_id
end

return keys
