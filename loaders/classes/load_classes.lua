function classes_loader.load_classes (themes)
  local start_time = os.clock()
  for _, theme in pairs(themes) do
    log.trace("Loading classes in theme " .. theme.name)
    classes_loader.process_files(theme)
  end
  local elapsed = (os.clock() - start_time) * 1000
  log.trace("Loaded classes in " .. elapsed .. " milliseconds")
end
