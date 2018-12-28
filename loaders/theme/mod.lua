themes = {}
themes_loader = {
  preprocessors = {}
}

require("loaders.theme.load_theme")
require("loaders.theme.scan_subdir")
require("loaders.theme.resolve_template")
require("loaders.theme.add_preprocessor")

require("loaders.theme.extends_rewriter")

function themes_loader.load_themes (themes_dir, main_theme, callback)
  themes_loader.main = main_theme
  themes_loader.dir = themes_dir
  themes_loader.load_theme(main_theme)

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

-- tera render function aware of theme paths
local _render = render
function _G.render (path, data)
  local theme = themes[themes_loader.main]
  local new_path = themes_loader.resolve_template(theme, path)
  return _render(new_path, data)
end

return themes_loader
