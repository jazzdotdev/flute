function themes_loader.copy_files_no_dot_checking(path_to_copy, dest_path)

    for _, filename in ipairs(fs.get_all_files_in(path_to_copy)) do
      local src = path_to_copy .. filename
      local dst = dest_path .. filename
      fs_lua.copy(src, dst)
    end
  
  end