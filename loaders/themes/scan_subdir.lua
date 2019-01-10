function themes_loader.scan_subdir (files, subdir, path)
  -- In here, I refer to dir as the subdirectory inside the theme directory
  -- and path to the actual location of the file

  local subpath = path .. subdir

  for entry in fs.entries(subpath) do
    local entry_path = subpath .. entry

    if fs.is_dir(entry_path) then
      -- Recurse directories
      themes_loader.scan_subdir(files, subdir .. entry .. "/", path)

    elseif fs.is_file(entry_path) then
      -- Add the file contents to the file list
      files[subdir .. entry] = fs.read_file(entry_path)
    end

  end
end
