-- Foreach package in packages path, get a list of every component from 
-- events.txt, disabled_actions.txt, rules/, and actions/
-- then run each loader
_G.packages_path = "packages" -- directory where packages are stored
-- Split packages path to more easily determine current package name
local packages_path_modules = _G.packages_path:split( "/" )
-- Count packages so to process the loop in the correct number of iterations?
local packages_path_length = #packages_path_modules
-- Add the packages to the Lua search path, so that each package's components
-- can be required using its name as if it was a Lua module, eg:
-- require "lighttouch-libs.actions.create_key"
package.path = package.path..";./packages/?.lua"

-- Foreach event, get its associated actions and the parameters needed for its actions
_G.events = { } -- events table
_G.events_actions = { } -- events_actions["event_name"] = { event_action1_req, event_action2_req, ... etc. }
_G.every_events_actions_parameters = { }

_G.rules = {} -- rules table to store them from all packages
_G.rules_priorities = {} -- table to store priorities of rules, so we can sort _G.rules table later by these priorities

_G.ansicolors = require 'third-party.ansicolors'

require "loaders.events"
require "loaders.actions"
require "loaders.rules"
require "loaders.models"

-- everything is loaded now.  delete the remaining temporarily generated component used to load
os.remove("module.lua")

for k,v in table.sorted_pairs(_G.rules_priorities, function(t,a,b) return t[b] < t[a] end) do
  table.insert(_G.rules, require(k))
end
