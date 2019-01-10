function styles_loader.get_matches_table(style_filename)
  local pattern = [[^((?:.+/)?)_style/(.+\.\w+)/(.+)\.txt$]]
  local regex_object = regex.new(pattern) 
  local matches = regex_object:capture(style_filename)

  return matches
end
