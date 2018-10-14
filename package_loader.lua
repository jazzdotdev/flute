---- PACKAGES STEP BY STEP

-- list directories in packages path
-- foreach dir create specific path to events.txt, disabled_actions.txt, rules and actions
-- 'trigger' the loaders

function string:split(sep) -- string split function to extracting package name
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

local utils = require "utils"
local debug = require "debug"
local luvent = require "Luvent"
local fs = require "fs"


_G.rules = {} -- rules table to store them from all packages
_G.events = { } -- events table
local packages_path = "packages" -- directory where packages are stored
-- Splitting packages path to easier determine the name of current package later
local packages_path_modules = packages_path:split( "/" )
local packages_path_length = #packages_path_modules
package.path = package.path..";./packages/?.lua" -- what is sense of this line? // Aleksander Wlodarczyk
--
--
-- Generating uuid to match the response with request
local request_process_event = luvent.newEvent()
events["requestProcess"] = request_process_event
events["resProcess"] = luvent.newEvent()
request_process_event:addAction(function ()
    local request = ctx.msg
    request.path_segments = request.path:split("/")
    debug.generate_uuid()
end)

-- rule interpretter
for k, v in pairs(fs.directory_list(packages_path)) do
    local package_name = v:split( "/" )[packages_path_length+1] -- split package path in "/" places and get the last word 

    local rule_files = fs.get_all_files_in(v .. "rules/") -- get all rules from this package
    
    for _, file_name in ipairs(rule_files) do
        if file_name ~= "lua_files/" then
            local rule_lua_path = "tmp-lua/" .. file_name
            local rule_path = packages_path .. "/" .. package_name .. "/rules/" .. file_name
            log.debug("[patch] rule " .. rule_path)

            --fs.copy(rule_path, rule_lua_path)
            local lua_rule = assert(io.open(rule_lua_path, "w+"))

            lua_rule:write("local function rule(request, events)\n\tlog.debug('rule " .. file_name .. " starting to evaluate')")
            
            for line in io.lines(rule_path) do
                lua_rule:write("\n\t" .. line)
            end

            lua_rule:write("\n\tlog.debug('rule " .. file_name .. " evaluated succesfully')")
            lua_rule:write("\nend\nreturn{\n\trule = rule\n}") -- bottom rule function wrapper
            lua_rule:close()

            --fs.append_to_start(rule_lua_path, "local function rule(req, events)\n\tlog.trace('rule " .. file_name .. " starting to evaluate')") -- upper rule function wrapper

        end
    end
end
---

for k, v in pairs (fs.directory_list(packages_path)) do
    local package_name = v:split( "/" )[packages_path_length+1] -- split package path in "/" places and get the last word 
    local events_strings = { } -- events names table
    local event_count = 0
    -- read events file
    local events_file = fs.read_file(v .. "events.txt")
    -- put each line into an strings array

    -- it does not register the events if they aren't followed by \n
    local s = ""
    for i=1, string.len(events_file) do
        if string.sub( events_file, i, i ) ~= '\n' then
            s = s .. string.sub( events_file, i, i )
        else
            table.insert( events_strings, s)
            s = ""
        end
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
        end
        event:addAction(function ()
            log.debug("event " .. name .. " triggered")
        end)
    end
    
    -- read disabled actions
    local disabled_actions = { }
    local disabled_actions_file = fs.read_file(v .. "disabled_actions.txt")
    local s = ""
    for i=1, string.len(disabled_actions_file) do
        if string.sub( disabled_actions_file, i, i ) ~= '\n' then
            s = s .. string.sub( disabled_actions_file, i, i )
        else
            table.insert( disabled_actions, s )
            s = ""
        end
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
    
    local action_files = fs.get_all_files_in(v .. "actions/")
    for _, file_name in ipairs(action_files) do
        log.debug("[patch] action " .. file_name)
        local action_file = assert(io.open(packages_path .. "/" .. package_name .. "/actions/" .. file_name, "r")) -- open yaml / pseudo lua action ifle
        local action_yaml = ""
        local line_num = 0

        for line in io.lines(packages_path .. "/" .. package_name .. "/actions/" .. file_name) do
            line_num = line_num + 1        
            action_yaml = action_yaml .. line .. "\n" -- get only yaml lines
            if line_num == 2 then break end
        end
        action_yaml_table = yaml.load(action_yaml) -- decode yaml to lua table
        local action_lua_file = assert(io.open("tmp-lua/" .. file_name, "w+")) -- w+ to override old files
        action_lua_file:write("local event = { \"" .. action_yaml_table.event[1] .. "\"") -- put values from yaml in lua form

        for _, yaml_event in ipairs(action_yaml_table.event) do
            if yaml_event ~= action_yaml_table.event[1] then 
                action_lua_file:write(', "' .. yaml_event .. '"') -- put all events to 'local event = { }'
            end
        end

        action_lua_file:write(" }")
        action_lua_file:write("\nlocal priority = " .. action_yaml_table.priority .. " \n\n")
        action_lua_file:write("local function action(request)\n") -- function wrapper

        line_num = 0

        for line in io.lines(packages_path .. "/" .. package_name .. "/actions/" .. file_name) do
            line_num = line_num + 1
            if line_num > 2 then
                action_lua_file:write(line .. "\n\t")
            end
        end

        action_lua_file:write("\nend\n\nreturn{\n\tevent = event,\n\taction = action,\n\tpriority = priority\n}") -- ending return
        action_lua_file:close()

        local loglua = require "log"
        local ansicolors = require 'ansicolors'

        loglua.error("Test of log.lua" .. ansicolors('%{underline} and underlines'))
        loglua.trace("Test of log.lua")
        loglua.info("Test of log.lua")
        loglua.fatal("Test of log.lua")
        loglua.warn("Test of log.lua")

        local action_require_name = "tmp-lua." .. string.sub( file_name, 0, string.len( file_name ) - 4 )
        local action_require = require(action_require_name)
        
        for k, v in pairs(action_require.event) do
            local action = _G.events[v]:addAction(
                function(req)
                    log.debug("action " .. file_name .. " about to run")
                    possibleResponse = action_require.action(req)
                    if possibleResponse ~= nil then
                        if possibleResponse.body ~= nil then
                            _G.returned_response = possibleResponse
                            if events["resProcess"] then
                                events["resProcess"]:trigger()
                            end
                        end
                    end
                    log.debug("action " .. file_name .. " ran succesfully")
                end
            )
            _G.events[v]:setActionPriority(action, action_require.priority)
            if isDisabled(file_name) then
                _G.events[v]:disableAction(action)
            end
        end
        
    end
end

-- interpreted rules loading
for k, v in pairs(fs.directory_list(packages_path)) do
    local package_name = v:split( "/" )[packages_path_length+1] -- split package path in "/" places and get the last word 

    local rule_files = fs.get_all_files_in(v .. "rules/") -- get all rules from this package

    for _, file_name in ipairs(rule_files) do
        if file_name ~= "lua_files/" then

            local rule_require_name = "tmp-lua." .. string.sub(file_name, 0, string.len( file_name ) - 4)
            local rule_require = require(rule_require_name)
            log.debug("[load] rule " .. rule_require_name)
            table.insert(_G.rules, rule_require)
        end
    end

end
--

