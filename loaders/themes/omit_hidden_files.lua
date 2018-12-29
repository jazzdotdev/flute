local function omit_hidden_files (themes)
  log.trace("Removing hidden theme files")

  for _, theme in pairs(themes) do
    for filename, _ in pairs(theme.files) do

      if filename:match("^%.") then
        theme.files[filename] = nil
      end
      
    end
  end
end

themes_loader.add_preprocessor(omit_hidden_files)