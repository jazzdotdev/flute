function themes_loader.resolve_template (theme, path)

  -- Try match the parent path pattern
  local parent_path = path:match("^%^/(.+)$")

  -- Only search locally if the parent path pattern was not matched
  if not parent_path then

    -- If file exists in theme, return it
    if theme.files[path] then
      return theme.dir .. path
    end
  else
    path = parent_path
  end

  -- Search in parents anyway
  for _, parent_name in ipairs(theme.info.parents) do
    local parent_theme = themes[parent_name]

    -- If file exists in theme, return it
    if parent_theme.files[path] then
      return parent_theme.dir .. path
    end
  end

  -- If no file was found in the current theme nor in any parent,
  -- return the given path as it was
  return path
end