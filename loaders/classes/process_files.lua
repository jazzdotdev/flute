function classes_loader.process_files(theme)
  for class_filename, classes in pairs(theme.files) do

    local matches = classes_loader.get_matches_table(class_filename)

    -- If current file is a class file
    if matches then
      log.trace("Processing class file " .. class_filename)

      local dir, basename, elem = matches:get(1), matches:get(2), matches:get(3)
      local filename = classes_loader.get_filename(dir, basename)
      classes_loader.process_content(theme, filename, elem, classes)

    end
  end
end