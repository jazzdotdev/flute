function contentdb.validate_document (header)
  if not header.model then
    return false, "document does not define a model"
  end

  local model, err = contentdb.get_validator(header.model)
  if not model then
    return false, err
  end
  
  return model:validate(header)
end