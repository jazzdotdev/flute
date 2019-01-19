function rules_loader.write_priority (created_file, header, priority)
  if priority > 100 then priority = 100 end

  created_file:write("local priority = " .. priority)
end
