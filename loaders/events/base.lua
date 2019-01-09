events_loader = { }

require("loaders.events.mod")

events_loader.create_base_events()

-- Loop over each package, parse its events, and create any not seen before

each(
  fs.directory_list(_G.packages_path),
  function (package_name)
    local start_time = os.clock()
    local package_path = _G.packages_path .. "/" .. package_name .. "/"
    local events_strings = events_loader.parse_events_list(package_name)
    events_loader.create_events( #events_strings, events_strings )
    events_loader.read_disabled_actions(package_path)
    local elapsed = (os.clock() - start_time) * 1000
    log.trace("Loaded events for " .. package_name .. " in " .. elapsed .. " milliseconds")
  end
)

return events_loader
