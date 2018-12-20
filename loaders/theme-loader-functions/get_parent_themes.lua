function themes_loader.get_parent_themes(config_path, theme_name)

    local theme_yaml = ""
    for line in io.lines(config_path) do
      theme_yaml = theme_yaml .. "\n" .. line -- get yaml from one of parent themes
    end
  
    local theme_yaml_table = yaml.to_table(theme_yaml)
    
    if theme_yaml_table.parent ~= nil then
      for k1, v1 in ipairs(theme_yaml_table.parent) do -- adding parents of each theme to themes to load
        log.debug("Found theme " .. v1 .. " as parent for " .. theme_name)
        table.insert(themes, v1)
      end
    end
  end