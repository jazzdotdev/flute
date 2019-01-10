function classes_loader.get_matches_table(class_filename)
  local pattern = [[^((?:.+/)?)_class/(.+\.\w+)/(.+)\.txt$]]
  local regex_object = regex.new(pattern) 
  local matches = regex_object:capture(class_filename)

  return matches
end