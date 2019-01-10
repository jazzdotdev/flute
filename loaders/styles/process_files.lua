function styles_loader.process_files(theme)
  for style_filename, styles in pairs(theme.files) do

    local matches = styles_loader.get_matches_table(style_filename)

    -- If current file is a style file
    if matches then
      log.trace("[processing] style file " .. style_filename)

      local dir, basename, elem = matches:get(1), matches:get(2), matches:get(3)
      local filename = styles_loader.get_filename(dir, basename)
      styles_loader.process_template(theme, filename, elem, styles)

    end
  end
end
