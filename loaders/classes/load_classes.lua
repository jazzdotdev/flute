function classes_loader.load_classes (themes)
  for _, theme in pairs(themes) do
    log.trace("Loading classes in theme " .. theme.name)
    classes_loader.process_files(theme)
  end
end
