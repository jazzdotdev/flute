function themes_loader.load_theme (name)
  local path = themes_loader.dir .. name .. "/"
  local files = {}
  themes_loader.scan_subdir(files, "", path)

  -- Add the file list to the global themes list
  themes[name] = files
end