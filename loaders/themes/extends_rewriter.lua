local function extends_rewriter (themes)
  log.trace("[rewriting] extends for theme X")

  for name, theme in pairs(themes) do
    for filename, _in in pairs(theme.files) do

      local pattern = "{%%%s+extends%s+['\"](.-)['\"]%s+%%}"
      local out, count = _in:gsub(pattern, function (path)

        local new_path = themes_loader.resolve_template(theme, path)
        return '{% extends "' .. new_path .. '" %}'

      end)

      if count > 0 then
        log.trace("[processed] " .. count .. " extend tags in " .. theme.dir .. filename)
        theme.files[filename] = out
      end
    end
  end
end

local function include_rewriter (themes)
  log.trace("[rewriting] include")

  for name, theme in pairs(themes) do
    for filename, _in in pairs(theme.files) do

      local pattern = "{%%%s+include%s+['\"](.-)['\"]%s+%%}"
      local out, count = _in:gsub(pattern, function (path)
      
        local new_path = themes_loader.resolve_template(theme, path)
        return '{% include "' .. new_path .. '" %}'

      end)
      
      if count > 0 then
        log.trace("[processed] " .. count .. " include tags in " .. theme.dir .. filename)
        theme.files[filename] = out
      end

    end
  end
end

themes_loader.add_preprocessor(extends_rewriter)
themes_loader.add_preprocessor(include_rewriter)
