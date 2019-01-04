<<<<<<< HEAD
function classes_loader.process_content(theme, filename, elem, classes)
=======
function classes_loader.process_content(theme, filename)
>>>>>>> 810b3c992a10cd1fabd90152238beace02937a30
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