function themes_loader.load_theme (name,is_parent)
  log.debug("[loading] theme " .. name)

  local path = themes_loader.dir .. name .. "/"

  local info_content = fs.read_file(path .. "info.yaml")
  if not info_content then
    log.error("info.yaml not found in theme " .. name)
    return
  end
  local info = yaml.to_table(info_content)

  local files = {}
  themes_loader.scan_subdir(files, "", path,is_parent,name)

  if info.parents then
    for _, parent in ipairs(info.parents) do
      -- here are only the parents

      themes_loader.load_theme(parent,true) -- create a parameter and when it is a parent change the name of the file in the scan sub dir
    end
  end

  -- Add the file list to the global themes list
  themes[name] = files
end