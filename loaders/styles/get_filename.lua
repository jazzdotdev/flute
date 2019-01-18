function styles_loader.get_filename(dir, basename)
  local filename = basename
  if dir ~= "" then
    filename = dir .. basename
  end
  
  return filename
end
