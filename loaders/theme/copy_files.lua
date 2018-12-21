function themes_loader.copy_files(path_to_copy, dest_path)

    log.trace("Path to copy: " .. path_to_copy)
    local files_in_dir = fs.read_dir(path_to_copy) -- get files from theme main or theme subdirectory
    for _, file_name in ipairs(files_in_dir) do
      local file_path = path_to_copy .. file_name
      local dest_of_file = dest_path .. file_name
      log.trace("Copy: " .. file_path .. " -> " .. dest_of_file)
  
      -- to avoid errors with .git and hidden folders 
      local aproved = true --the element is aproved to be added 
      if string.find(dest_path, "/.") ~= nil then -- if the element folder name starts with a dot ".git"
        aproved = false -- the element is not aproved then must be ignored
      end
      --end of checking 
  
      if not fs.exists(dest_of_file) and fs.is_file(file_path) and aproved then -- if file not exist and file is not directory and file not aproved
        fs_lua.copy(file_path, dest_of_file)
      end
    end
  
  end