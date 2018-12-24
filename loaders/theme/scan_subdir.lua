function themes_loader.scan_subdir (files, subdir, path,is_parent,parent_name)
  -- In here, I refer to dir as the subdirectory inside the theme directory
  -- and path to the actual location of the file

  local subpath = path .. subdir

  for entry in fs.entries(subpath) do
    local entry_path = subpath .. entry
    local file_name 

    if fs.is_dir(entry_path) then
      -- Recurse directories
      themes_loader.scan_subdir(files, subdir .. entry .. "/", path,is_parent,parent_name)

    elseif fs.is_file(entry_path) then
      -- Add the file contents to the file list
      if string.find(entry, "html") ~= nil and is_parent then
        -- body
        file_name = subdir .. parent_name .. "-" .. entry
      else
        file_name = subdir .. entry        
      end

      log.debug("Name of the File : " .. file_name)

      files[subdir .. entry] = fs.read_file(entry_path) -- create a parameter and when it is a parent change the name of the file in the scan sub dir
    end

  end
end