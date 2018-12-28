local function extends_rewriter (themes)
  log.trace("Rewriting extends")

  for name, theme in pairs(themes) do
    for filename, _in in pairs(theme.files) do

      local pattern = "{%%%s+extends%s+['\"](.+)['\"]%s+%%}"
      local out, count = _in:gsub(pattern, function (path)

        local new_path = themes_loader.resolve_template(theme, path)
        return '{% extends "' .. new_path .. '" %}'

      end)

      if count > 0 then
        log.trace("Processed " .. count .. " extend tags in " .. theme.dir .. filename)
        theme.files[filename] = out
      end
    end
  end
end

themes_loader.add_preprocessor(extends_rewriter)