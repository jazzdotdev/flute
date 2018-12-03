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
