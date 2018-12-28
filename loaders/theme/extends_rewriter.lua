local function extends_rewriter (themes)
  log.trace("Rewriting extends")

  for name, theme in pairs(themes) do
    for filename, _in in pairs(theme.files) do
      
      local pattern = "{%%%s+extends%s+['\"](.+)['\"]%s+%%}"
      local out, count = _in:gsub(pattern, function (path)

        local function surround (path)
          return '{% extends "' .. path .. '" %}'
        end

        -- Try match the parent path pattern
        local parent_path = path:match("^%^/(.+)$")

        -- Only search locally if the parent path pattern was not matched
        if not parent_path then

          -- If file exists in theme, return it
          if theme.files[path] then
            return surround(theme.dir .. path)
          end
        else
          path = parent_path
        end

        -- Search in parents anyway
        for _, parent_name in ipairs(theme.info.parents) do
          local parent_theme = themes[parent_name]

          -- If file exists in theme, return it
          if parent_theme.files[path] then
            return surround(parent_theme.dir .. path)
          end
        end

        -- If no template was found in the local theme nor in any parent,
        -- return the given path as it was
        return surround(path)
      end)

      if count > 0 then
        log.trace("Processed " .. count .. " extend tags in " .. theme.dir .. filename)
        theme.files[filename] = out
      end
    end
  end
end

themes_loader.add_preprocessor(extends_rewriter)