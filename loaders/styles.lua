styles_loader = { }

require("loaders.styles.mod")

function load_styles (themes)
  for _, theme in pairs(themes) do
    log.trace("[loading] styles in theme " .. theme.name)
    styles_loader.process_files(theme)
  end
end


themes_loader.add_preprocessor(load_styles)
