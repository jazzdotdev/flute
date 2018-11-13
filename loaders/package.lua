---- PACKAGES STEP BY STEP

-- list directories in packages path
-- foreach dir create specific path to events.txt, disabled_actions.txt, rules and actions
-- 'trigger' the loaders

_G.ansicolors = require 'third-party.ansicolors'
_G.every_events_actions_parameters = { }
_G.events_actions = { } -- events_actions["event_name"] = { event_action1_req, event_action2_req, ... etc. }

_G.rules = {} -- rules table to store them from all packages
_G.rules_priorities = {} -- table to store priorities of rules, so we can sort _G.rules table later by these priorities
_G.events = { } -- events table
_G.packages_path = "packages" -- directory where packages are stored
-- Splitting packages path to easier determine the name of current package later
local packages_path_modules = _G.packages_path:split( "/" )
local packages_path_length = #packages_path_modules
-- Adds the packages into the lua search path, so that a package's content
-- can be required using it's name as if it was a lua module, ej:
-- require "lighttouch-libs.actions.create_key"
package.path = package.path..";./packages/?.lua"


require "loaders.events"
require "loaders.actions"
require "loaders.rules"

-- everything is loaded now
os.remove("module.lua")
--

for k,v in table.sorted_pairs(_G.rules_priorities, function(t,a,b) return t[b] < t[a] end) do
    table.insert(_G.rules, require(k))
end
--

