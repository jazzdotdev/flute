---- PACKAGES STEP BY STEP

-- list directories in packages path
-- foreach dir create specific path to events.txt, disabled_actions.txt, rules and actions
-- 'trigger' the loaders

local log = require "log"
local ansicolors = require 'ansicolors'

events_actions = { }
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

local request_process_event = luvent.newEvent()
events["incoming_request_received"] = request_process_event
events["outgoing_response_about_to_be_sent"] = luvent.newEvent()
function request_process_action ()
    log.trace("\tNew request received") -- temporary it can be here
    local request = ctx.msg
    request.path_segments = request.path:split("/")
end
request_process_event:addAction(request_process_action)
request_process_event:setActionPriority(request_process_action, 100)


-- rule interpretter
for k, v in pairs(fs.directory_list(packages_path)) do
    local package_name = v:split( "/" )[packages_path_length+1] -- split package path in "/" places and get the last word 
    os.execute("mkdir -p tmp-lua/" .. package_name .. "/rules")
    local rule_files = fs.get_all_files_in(v .. "rules/") -- get all rules from this package
    
    for _, file_name in ipairs(rule_files) do
        if file_name ~= "lua_files/" then
            local rule_lua_path = "tmp-lua/" .. package_name .. "/" .. "rules/" .. file_name
            local rule_path = packages_path .. "/" .. package_name .. "/rules/" .. file_name
            log.trace("[Rule] Patching " .. ansicolors('%{underline}' .. file_name))

            local rule_yaml = ""
            local rule_yaml_table
            local line_num = 0
            for line in io.lines(rule_path) do
                line_num = line_num + 1        
                rule_yaml = rule_yaml .. line .. "\n" -- get only yaml lines
                if line_num == 3 then break end
            end

            rule_yaml_table = yaml.load(rule_yaml)

            -- rule weight cannot be higher than 100

            local weight = rule_yaml_table.weight or 1
            if weight > 100 then weight = 100 end

            --fs.copy(rule_path, rule_lua_path)
            local lua_rule = assert(io.open(rule_lua_path, "w+"))
            
            lua_rule:write("local log = require \"log\"\n")
            lua_rule:write("\nlocal weight = " .. weight)
            lua_rule:write("\nlocal event = " .. "\"rule_yaml_table.event\"")
            lua_rule:write("\nlocal parameters = {")
            for k, v in pairs(rule_yaml_table.parameters) do
                if k == 1 then
                    lua_rule:write(" \"" .. v .. "\"")
                else
                    lua_rule:write(", \"" .. v .. "\"")
                end
            end
            lua_rule:write(" }")
            lua_rule:write("\nlocal function rule(arguments)")
            lua_rule:write("\n\tlog.debug('[Rule] " .. ansicolors('%{underline}' .. file_name) .. " with weight " .. weight .. " starting to evaluate')")
            
            line_num = 0
            for line in io.lines(rule_path) do
                line_num = line_num + 1
                if line_num > 3 then
                    lua_rule:write("\n\t" .. line)
                end
            end

            lua_rule:write("\n\tlog.debug('[Rule] " .. ansicolors('%{underline}' .. file_name) .. " evaluated succesfully')")
            lua_rule:write("\nend")
            lua_rule:write("\n\nfunction get_action_parameters(events_actions)")
            lua_rule:write("\n\tfor k, v in pairs(events_actions[event]) do")
            lua_rule:write("\n\t\tfor k1, v1 in pairs(v[1].input_parameters) do")
            lua_rule:write("\n\t\t\ttable.insert(parameters, v1)")
            lua_rule:write("\n\t\tend")
            lua_rule:write("\n\tend")
            lua_rule:write("\nend")
            lua_rule:write("\nreturn{\n\trule = rule,\n\tweight = weight,\n\tparameters = parameters\n}") -- bottom rule function wrapper
            lua_rule:close()

            --fs.append_to_start(rule_lua_path, "local function rule(req, events)\n\tlog.trace('rule " .. file_name .. " starting to evaluate')") -- upper rule function wrapper
            -- Rules know which event are they triggering. They don't know the action
            -- We have to have events - actions table to get it done
        end
    end
end
---

for k, v in pairs (fs.directory_list(packages_path)) do

    local package_name = v:split( "/" )[packages_path_length+1] -- split package path in "/" places and get the last word 

    log.trace("[Package] Patching actions for " .. ansicolors('%{underline}' .. package_name))

    local events_strings = { } -- events names table
    local event_count = 0
    -- read events file
    local events_file = fs.read_file(v .. "events.txt")

    -- put each line into a strings array
    for line in fs.read_lines(v .. "events.txt") do
        table.insert( events_strings, line )
    end
    
    -- count the lines
    
    for _ in pairs(events_strings) do
        event_count = event_count + 1
    end
    
    -- create events
    
    for i=1, event_count do
        local name = events_strings[i]
        events_actions[name] = { }
        local event = _G.events[name]
        if not event then
            event = luvent.newEvent()
            _G.events[name] = event
        end
        event:addAction(function ()
            log.debug("[Event] " .. ansicolors('%{underline}' .. name) .. " triggered")
        end)
    end
    
    -- read disabled actions
    local disabled_actions = { }
    for line in fs.read_lines(v .. "disabled_actions.txt") do
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
    
    local action_files = fs.get_all_files_in(v .. "actions/")
    os.execute("mkdir -p tmp-lua/" .. package_name .. "/actions")
    for _, file_name in ipairs(action_files) do
        log.trace("[Action] Patching " .. ansicolors('%{underline}' .. file_name))
        local action_file = assert(io.open(packages_path .. "/" .. package_name .. "/actions/" .. file_name, "r")) -- open yaml / pseudo lua action ifle
        local action_yaml = ""
        local line_num = 0

        for line in io.lines(packages_path .. "/" .. package_name .. "/actions/" .. file_name) do
            line_num = line_num + 1        
            action_yaml = action_yaml .. line .. "\n" -- get only yaml lines
            if line_num == 3 then break end
        end
        action_yaml_table = yaml.load(action_yaml) -- decode yaml to lua table
        local action_lua_file = assert(io.open("tmp-lua/" .. package_name .. "/actions/" .. file_name, "w+")) -- w+ to override old files
        action_lua_file:write("local event = { \"" .. action_yaml_table.event[1] .. "\"") -- put values from yaml in lua form

        for _, yaml_event in ipairs(action_yaml_table.event) do
            if yaml_event ~= action_yaml_table.event[1] then 
                action_lua_file:write(', "' .. yaml_event .. '"') -- put all events to 'local event = { }'
            end
        end

        action_lua_file:write(" }")
        action_lua_file:write("\nlocal weight = " .. action_yaml_table.weight .. " \n\n")
        action_lua_file:write("local log = require \"log\"\n")
        action_lua_file:write("local input_parameters = {")
        for k, v in pairs(action_yaml_table.input_parameters) do
            if k == 1 then
                action_lua_file:write(" \"" .. v .. "\"")
            else
                action_lua_file:write(", \"" .. v .. "\"")
            end
        end
        action_lua_file:write("}")
        action_lua_file:write("\nlocal function action(arguments)\n") -- function wrapper

        line_num = 0

        for line in io.lines(packages_path .. "/" .. package_name .. "/actions/" .. file_name) do
            line_num = line_num + 1
            if line_num > 3 then
                action_lua_file:write(line .. "\n\t")
            end
        end

        action_lua_file:write("\nend")
        action_lua_file:write("\n\nreturn{\n\tevent = event,\n\taction = action,\n\tweight = weight,\n\tinput_parameters = input_parameters\n}") -- ending return
        action_lua_file:close()

        local action_require_name = "tmp-lua." .. package_name .. ".actions." .. string.sub( file_name, 0, string.len( file_name ) - 4 )
        local action_require = require(action_require_name)
        
        for k, v in pairs(action_require.event) do
            local event = _G.events[v]
            if event then
                table.insert( events_actions[v] , action_require )
                local action = event:addAction(
                    function(arguments)
                        log.debug("[Action] " .. ansicolors('%{underline}' .. file_name) .. " with weight " .. action_yaml_table.weight .. " is about to run")
                        -- TODO: figure out what to do if more than one responses are returned
                        possible_response = action_require.action(arguments) -- we are parsing here the req, what if action need more params?
                        if possible_response ~= nil then
                            if possible_response.body ~= nil then
                                _G.returned_response = possible_response
                                if events["outgoing_response_about_to_be_sent"] then
                                    events["outgoing_response_about_to_be_sent"]:trigger()
                                end
                            end
                        end
                        log.debug("[Action] " .. ansicolors('%{underline}' .. file_name) .. " ran succesfully")
                    end
                )
                event:setActionPriority(action, action_require.weight)
                if isDisabled(file_name) then
                    event:disableAction(action)
                end
            else
                log.error("event " .. v .. " doesn't exist")
            end
        end 
    end

    log.trace("[Package] Finished patching actions for " .. ansicolors('%{underline}' .. package_name))
end

-- interpreted rules loading
for k, v in pairs(fs.directory_list(packages_path)) do
    local package_name = v:split( "/" )[packages_path_length+1] -- split package path in "/" places and get the last word 

    local rule_files = fs.get_all_files_in(v .. "rules/") -- get all rules from this package

    for _, file_name in ipairs(rule_files) do
        if file_name ~= "lua_files/" then

            local rule_require_name = "tmp-lua." .. package_name .. ".rules." .. string.sub(file_name, 0, string.len( file_name ) - 4)
            local rule_require = require(rule_require_name)
            log.debug("[Rule] Loading " .. ansicolors('%{underline}' .. rule_require_name))

            --table.insert(_G.rules, rule_require)
            _G.rules_priorities[rule_require_name] = rule_require.weight
        end
    end

end

for k,v in sorted_pairs(_G.rules_priorities, function(t,a,b) return t[b] < t[a] end) do
    table.insert(_G.rules, require(k))
end

--

