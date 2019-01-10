function styles_loader.process_template(theme, filename, elem, styles)
  local template = theme.files[filename]

  -- Execute the sustitution
  if template then

    -- Either an id or just a tag name
    if elem:sub(1,1) == "#" then
      local id = elem:sub(2, -1)
      template = string.gsub(template,
        "<([^>]*%sid=\"" .. id .. "\"[^>]*)>",
        "<%1 class=\"\n" .. styles .. "\">"
      )
    else
      -- This *maaay* break if a tag name contains another tag name at the beggining
      template = string.gsub(template,
        "<(" .. elem .. "[^>]*)>",
        "<%1 class=\"\n" .. styles .. "\">"
      )
    end

    theme.files[filename] = template
  else
    log.error("File " .. filename .. " not found")
  end
end
