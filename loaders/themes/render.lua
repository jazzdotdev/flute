-- tera render function aware of theme paths
local _render = render
function _G.render (path, data)
  local theme = themes[themes_loader.main]
  local new_path = themes_loader.resolve_template(theme, path)
  return _render(new_path, data)
end