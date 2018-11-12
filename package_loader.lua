---- PACKAGES STEP BY STEP

-- list directories in packages path
-- foreach dir create specific path to events.txt, disabled_actions.txt, rules and actions
-- 'trigger' the loaders

_G.ansicolors = require 'third-party.ansicolors'
_G.every_events_actions_parameters = { }
local events_actions = { } -- events_actions["event_name"] = { event_action1_req, event_action2_req, ... etc. }

_G.rules = {} -- rules table to store them from all packages
_G.rules_priorities = {} -- table to store priorities of rules, so we can sort _G.rules table later by these priorities
_G.events = { } -- events table
local packages_path = "packages" -- directory where packages are stored
-- Splitting packages path to easier determine the name of current package later
local packages_path_modules = packages_path:split( "/" )
local packages_path_length = #packages_path_modules
-- Adds the packages into the lua search path, so that a package's content
-- can be required using it's name as if it was a lua module, ej:
-- require "lighttouch-libs.actions.create_key"
package.path = package.path..";./packages/?.lua"

require "custom_loaders"

events["lighttouch_loaded"] = luvent.newEvent()
events_actions["lighttouch_loaded"] = { }

events["incoming_request_received"] = luvent.newEvent()
events_actions["incoming_request_received"] = { }

events["outgoing_response_about_to_be_sent"] = luvent.newEvent()
events_actions["outgoing_response_about_to_be_sent"] = { }

events["document_created"] = luvent.newEvent()
events_actions["document_created"] = { }

events["incoming_response_received"] = luvent.newEvent()
events_actions["incoming_response_received"] = { }

events["outgoing_request_about_to_be_sent"] = luvent.newEvent()
events_actions["outgoing_request_about_to_be_sent"] = { }

for k, package_name in pairs (fs.directory_list(packages_path)) do
    local package_path = packages_path .. "/" .. package_name .. "/"

    log.trace("[patching] actions for package " .. ansicolors('%{underline}' .. package_name))

    local events_strings = { } -- events names table
    local event_count = 0

    -- put each line into a strings array
    for line in fs.read_lines(package_path .. "events.txt") do
        table.insert( events_strings, line )
    end
    
    -- count the lines
    
    for _ in pairs(events_strings) do
        event_count = event_count + 1
    end
    
    -- create events
    
    for i=1, event_count do
        local name = events_strings[i]
        local event = _G.events[name]
        if not event then
            event = luvent.newEvent()
            _G.events[name] = event
            events_actions[name] = { } -- create table of actions for that event
        end
        event:addAction(function ()
            log.debug("[triggering] event"  .. ansicolors('%{underline}' .. name) )
        end)
    end
    
    -- read disabled actions
    local disabled_actions = { }
    for line in fs.read_lines(package_path .. "disabled_actions.txt") do
        table.insert( disabled_actions, line )
    end
    ---
    function isDisabled(action_file_name)
        for k, v in pairs(disabled_actions) do
            if action_file_name == v then 
                return true 
            end
        end
    
        return false
    end
    -- actions loader
    
    local actions_path = package_path .. "actions/"
    local action_files = {} -- actions path is optional
    if fs.exists(actions_path) then
        action_files = fs.get_all_files_in(actions_path)
    end

    for _, file_name in ipairs(action_files) do
        log.trace("[patching] action " .. ansicolors('%{underline}' .. file_name))

        local action_require_name = "packages." .. package_name .. ".actions." .. string.sub( file_name, 0, string.len( file_name ) - 4 )
        local action_require = require(action_require_name)
        
        for k, v in pairs(action_require.event) do
            local event = _G.events[v]
            if event then
                table.insert( events_actions[v], action_require )
                local action = event:addAction(
                    function(action_arguments) -- ISSUE: we have to declare here as much arguments as the action needs(maybe do a table of arguments?)
                        log.debug("[running] action " .. ansicolors('%{underline}' .. file_name) .. " with priority " .. action_require.priority )
                        -- TODO: figure out what to do if more than one responses are returned
                        possibleResponse = action_require.action(action_arguments)
                        if possibleResponse ~= nil then
                            if possibleResponse.body ~= nil then
                                _G.response = possibleResponse
                                if events["outgoing_response_about_to_be_sent"] then
                                    events["outgoing_response_about_to_be_sent"]:trigger()
                                end
                            end
                        end
                        log.debug("[completed] action " .. ansicolors('%{underline}' .. file_name) )
                    end
                )
                event:setActionPriority(action, action_require.priority)
                if isDisabled(file_name) then
                    event:disableAction(action)
                end
            else
                log.error("event " .. v .. " doesn't exist")
            end
        end 
    end

    log.trace("[patched] actions for package " .. ansicolors('%{underline}' .. package_name))
end
-- 


-- interpreted rules loading
for k, package_name in pairs(fs.directory_list(packages_path)) do

    local rules_path = packages_path .. "/".. package_name .. "/rules/"
    local rule_files = {} -- get all rules from this package
    -- Rules path is optional
    if fs.exists(rules_path) then
        rule_files = fs.get_all_files_in(rules_path)
    end

    for _, file_name in ipairs(rule_files) do
        if file_name ~= "lua_files/" then

            local rule_require_name = "packages." .. package_name .. ".rules." .. string.sub(file_name, 0, string.len( file_name ) - 4)
            local rule_require = require(rule_require_name)
            rule_require.get_events_parameters(events_actions) -- let the rule know which parameters it needs to its events actions
            log.debug("[loading] rule " .. ansicolors('%{underline}' .. rule_require_name))

            --table.insert(_G.rules, rule_require)
            _G.rules_priorities[rule_require_name] = rule_require.priority
        end
    end

end

-- everything is loaded now
os.remove("tmp-lua/module.lua")
--

for k,v in table.sorted_pairs(_G.rules_priorities, function(t,a,b) return t[b] < t[a] end) do
    table.insert(_G.rules, require(k))
end
--

