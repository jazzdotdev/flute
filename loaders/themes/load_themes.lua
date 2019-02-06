function themes_loader.load_themes (themes_dir, theme, callback)
  themes_loader.theme = theme
  themes_loader.dir = themes_dir
  themes_loader.load_theme(theme)

  for _, fn in ipairs(themes_loader.preprocessors) do
    fn(themes)
  end

  local all_files = {}
  for name, theme in pairs(themes) do
    for filename, contents in pairs(theme.files) do
      all_files[theme.dir .. filename] = contents
    end
  end

  tera.instance:add_raw_templates(all_files)
end
