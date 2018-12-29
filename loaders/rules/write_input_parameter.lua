function rules_loader.write_input_parameter (created_file, header)
  created_file:write("\nlocal input_parameter = \"" .. header.input_parameter .. "\"")
end