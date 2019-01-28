function keys.connect_profile (data)

  local result = {}

  local profile_uuid = data.uuid
  result.profile = profile_uuid

  content.write_file(profile_uuid, profile_uuid, {
    type = "profile",
    name = data.name
  })

  if data.sign_public_key then
    local sign_pub_id = uuid.v4()

    content.write_file(profile_uuid, uuid.v4(), {
      type = "key",
      kind = "sign_public",
    }, data.sign_public_key)

    result.sign_public_key = sign_pub_id
  end

  if data.place then
    local place_id = uuid.v4()

    content.write_file(profile_uuid, uuid.v4(), {
      type = "place",
      host = data.place,
    })

    result.place = place_id
  end

  return result
end