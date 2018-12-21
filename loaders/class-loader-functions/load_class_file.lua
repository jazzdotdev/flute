function class_loader.load_class_file (file_name)
    log.trace("Loading class file " .. file_name)
    local template_file, element_specifier = file_name:match("^(.+%.%w+)%-(.+)%.txt")
  
    if not template_file then
      log.error(file_name .. " is not a valid class filename")
      return
    end
  
  
    local class_path = class_dir .. file_name
    local classes = fs.read_file(class_path)
    if not classes then
      log.error("Couldn't read " .. class_path)
      return
    end
  
    local path = "temp-theme/" .. template_file
    local template = fs.read_file(path)
    if not template then
      log.error("Couldn't read " .. path)
      return
    end
  
  
    if element_specifier:sub(1,1) == "#" then
      -- element id
      local id = element_specifier:sub(2, -1)
  
      template = string.gsub(template,
        "<([^>]*%sid=\"" .. id .. "\"[^>]*)>",
        "<%1 class=\"\n" .. classes .. "\">"
      )
    else
      -- Tag name case
  
      -- This *maaay* break if a tag name contains another tag name at the beggining
      template = string.gsub(template,
        "<(" .. element_specifier .. "[^>]*)>",
        "<%1 class=\"\n" .. classes .. "\">"
      )
    end
  
    print(template)
  
    print("<(" .. element_specifier .. "[^>])>", replace_str)
  
    local file = io.open(path, "w+")
    file:write(template)
    file:close()
  end