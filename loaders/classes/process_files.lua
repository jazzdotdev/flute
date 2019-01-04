function classes_loader.process_files(theme)
  for class_filename, classes in pairs(theme.files) do

    local matches = classes_loader.get_matches_table(class_filename)

    -- If current file is a class file
    if matches then
      log.trace("Processing class file " .. class_filename)

      local dir, basename, elem = matches:get(1), matches:get(2), matches:get(3)
      local filename = classes_loader.get_filename(dir, basename)
<<<<<<< HEAD
      classes_loader.process_content(theme, filename, elem, classes)
=======
      classes_loader.process_content(theme, filename)
>>>>>>> 810b3c992a10cd1fabd90152238beace02937a30

    end
  end
end