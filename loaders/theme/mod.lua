themes = {}
themes_loader = {}

require("loaders.theme.load_theme")
require("loaders.theme.scan_subdir")

local function load_themes(themes_dir, main_theme, callback)
  themes_loader.dir = themes_dir
  themes_loader.load_theme(main_theme,false)

  if callback then
    callback(themes)
  end

  local all_files = {}
  for theme_name, files in pairs(themes) do
    for filename, contents in pairs(files) do
      all_files[filename] = contents
    end
  end

  tera.instance:add_raw_templates(all_files)
end

return {
  load_themes = load_themes
}
