function contentdb.get_validator (name)
  local model_def = models[name]
  if not model_def then
    return nil, "Model " .. name .. " not found"
  end
  
  for name, field_def in pairs(model_def.fields) do
    local validator = valua:new()
  
    if field_def.optional then
      validator.optional(true)
    end
  
    if field_def.type == "number" then
      validator.number()
    elseif field_def.type == "integer" then
      validator.integer()
    elseif field_def.type == "string" then
      validator.string()
    else
      return nil, "missing type in field " .. name
    end
  
    fields[name] = validator
  end
  
  local model = setmetatable({
    fields = fields
  }, model_metatable)
  
  return model
end