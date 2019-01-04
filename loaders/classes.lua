local function load_classes (themes)
  for _, theme in pairs(themes) do
    log.trace("Loading classes in theme " .. theme.name)

    for class_filename, classes in pairs(theme.files) do
      --local pattern = "^(.+/)_class/(.+%.%w+)%-(.+)%.txt$"
      --local dir, basename, elem = class_filename:match(pattern)
      
      local pattern = [[^((?:.+/)?)_class/(.+\.\w+)/(.+)\.txt$]]
      local regex_object = regex.new(pattern) 
      local matches = regex_object:capture(class_filename)

      -- If current file is a class file
      if matches then
        log.trace("Processing class file " .. class_filename)

        local dir, basename, elem = matches[2], matches[3], matches[4]

        local filename = basename
        if dir ~= "" then
          filename = dir .. basename
        end

        local content = theme.files[filename]

        -- Execute the sustitution
        if content then

          -- Either an id or just a tag name
          if elem:sub(1,1) == "#" then
            local id = elem:sub(2, -1)
            content = string.gsub(content,
              "<([^>]*%sid=\"" .. id .. "\"[^>]*)>",
              "<%1 class=\"\n" .. classes .. "\">"
            )
          else
            -- This *maaay* break if a tag name contains another tag name at the beggining
            content = string.gsub(content,
              "<(" .. elem .. "[^>]*)>",
              "<%1 class=\"\n" .. classes .. "\">"
            )
          end

          theme.files[filename] = content
        else
          log.error("File " .. filename .. " not found")
        end
      end
    end
  end
end

themes_loader.add_preprocessor(load_classes)
