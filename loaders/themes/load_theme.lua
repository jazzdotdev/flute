function themes_loader.load_theme (name)
  log.trace("[loading] theme " .. name)

  local path = themes_loader.dir .. name .. "/"

  local info_content = fs.read_file(path .. "info.yaml")
  if not info_content then
    log.error("info.yaml not found in theme " .. name)
    return
  end
  local info = yaml.to_table(info_content)

  local files = {}
  themes_loader.scan_subdir(files, "", path)

  if info.parents then
    for _, parent in ipairs(info.parents) do
      themes_loader.load_theme(parent)
    end
  end

  -- Add the file list to the global themes list
  themes[name] = {
    name = name,
    info = info,
    files = files,
    dir = name .. "/",
  }
end