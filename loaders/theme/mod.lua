themes = {}
themes_loader = {
  preprocessors = {}
}

require("loaders.theme.load_theme")
require("loaders.theme.scan_subdir")
require("loaders.theme.add_preprocessor")

function themes_loader.load_themes (themes_dir, main_theme, callback)
  themes_loader.dir = themes_dir
  themes_loader.load_theme(main_theme,false)

  for _, fn in ipairs(themes_loader.preprocessors) do
    fn(themes)
  end

  local all_files = {}
  for theme_name, files in pairs(themes) do
    for filename, contents in pairs(files) do
      all_files[filename] = contents
    end
  end

  tera.instance:add_raw_templates(all_files)
end

return themes_loader
