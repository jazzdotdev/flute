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