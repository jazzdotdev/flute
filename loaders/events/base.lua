events_loader = { }

require("loaders.events.mod")

events_loader.create_base_events()

-- Loop over each package, parse its events, and create any not seen before

each(
  fs.directory_list(_G.packages_path),
  function (packge_name)
    local events_strings = events_loader.parse_events_list(packge_name)
    events_loader.create_events( #events_strings, events_strings )
  end
)

return events_loader
