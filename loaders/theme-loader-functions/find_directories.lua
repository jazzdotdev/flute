function themes_loader.find_directories(path_to_copy, paths)

    dirs = fs_lua.directory_list(path_to_copy) -- get list of directories in current location
  
    for k, v in pairs(dirs) do
  
      table.insert( paths, path_to_copy .. v)
      log.trace("Found directory: " .. v)
    end
  
  end