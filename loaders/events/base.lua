events_loader = { }

require("loaders.events.mod")

-- Actual Setup

events_loader.create_base_events()

-- Runs the function against all packages in packages_path
each(fs.directory_list(_G.packages_path), events_loader.parse_and_create_events)

return events_loader