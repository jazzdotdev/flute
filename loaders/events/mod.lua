require("loaders.events.base")
require("loaders.events.count_lines")
require("loaders.events.create_base_events")
require("loaders.events.read_disabled_actions")
require("loaders.events.create_events")
require("loaders.events.count_and_create_events")

-- Actual Setup

events_loader.create_base_events()

-- Runs the function against all packages in packages_path
each(fs.directory_list(_G.packages_path), events_loader.count_and_create_events)
