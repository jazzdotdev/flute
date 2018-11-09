---- PACKAGES STEP BY STEP

-- list directories in packages path
-- foreach dir create specific path to events.txt, disabled_actions.txt, rules and actions
-- 'trigger' the loaders

-- package.searchers test
-- package.searchers[2] - function for processing required module

    package.preload["awdgb"] = function(name) print('test', name) end

    require "awdgb"

    -- so i have to change package.preload[reqire_path] to change file while loading

    local default_package_searchers2 = package.searchers[2]
    package.searchers[2] = function(name) 
        if string.match( name, "rules") then
            print("name " .. name) -- interpretate rule code and return it
            local file_path = package.searchpath(name, "?.lua")
            local pure_file_io = io.open(file_path)
            pure_file_io:write("\n\n-- rule loaded with custom loader")
            local pure_file = loadfile(file_path)
            return pure_file
            --return default_package_searchers2(name) -- tmp for now / it'll be deleted

        elseif string.match( name, "actions" ) then
            package.preload[name] = function(modulename)
                log.warn("custom require")
                local modulepath = string.gsub(modulename, "%.", "/")
                for path in string.gmatch(package.path, "([^;]+)") do
                    local filename = string.gsub(path, "%?", modulepath)
                    local created_file = io.open("tmp-lua/testfile.lua", "w+")
                    created_file:write("test")
                  local file = io.open(filename, "rb")
                  if file then
                    file:write("awdgb")
                    -- Compile and return the module
                    return assert(load(assert(file:read("*a")), filename))
                  end
                end
            end

            return require(name)
            
            --return default_package_searchers2(name) -- tmp for now / it'll be deleted

        else
            print(name) -- else default return so it won't change code of other modules (f.e. log or ansicolors)
            return default_package_searchers2(name)
        end

    end
--

local log = require "log"
local ansicolors = require 'third-party.ansicolors'
local every_events_actions_parameters = { }
local events_actions = { } -- events_actions["event_name"] = { event_action1_req, event_action2_req, ... etc. }

local utils = require "utils"

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

events["lighttouch_loaded"] = luvent.newEvent()
events_actions["lighttouch_loaded"] = { }

events["incoming_request_received"] = luvent.newEvent()
events_actions["incoming_request_received"] = { }

events["outgoing_response_about_to_be_sent"] = luvent.newEvent()
events_actions["outgoing_response_about_to_be_sent"] = { }

events["document_created"] = luvent.newEvent()
events_actions["document_created"] = { }

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

    fs.create_dir("tmp-lua/" .. package_name .. "/actions/", true)
    for _, file_name in ipairs(action_files) do
        log.trace("[patching] action " .. ansicolors('%{underline}' .. file_name))
        local action_file = assert(io.open(packages_path .. "/" .. package_name .. "/actions/" .. file_name, "r")) -- open yaml / pseudo lua action ifle
        local action_yaml = ""
        local line_num = 0

        for line in io.lines(packages_path .. "/" .. package_name .. "/actions/" .. file_name) do
            line_num = line_num + 1        
            action_yaml = action_yaml .. line .. "\n" -- get only yaml lines
            if line_num == 3 then break end
        end
        action_yaml_table = yaml.to_table(action_yaml) -- decode yaml to lua table
        local action_lua_file = assert(io.open("tmp-lua/" .. package_name .. "/actions/" .. file_name, "w+")) -- w+ to override old files
        action_lua_file:write("local event = { \"" .. action_yaml_table.event[1] .. "\"") -- put values from yaml in lua form

        for _, yaml_event in ipairs(action_yaml_table.event) do
            if yaml_event ~= action_yaml_table.event[1] then 
                action_lua_file:write(', "' .. yaml_event .. '"') -- put all events to 'local event = { }'
            end
        end

        action_lua_file:write(" }")
        action_lua_file:write("\nlocal priority = " .. action_yaml_table.priority .. " \n\n")
        action_lua_file:write("local log = require \"log\"\n")
        if action_yaml_table.input_parameters[1] then
            action_lua_file:write("local input_parameters = { " .. "\"" .. action_yaml_table.input_parameters[1] .. "\"")
            for k, v in pairs(action_yaml_table.input_parameters) do
                if not utils.table_contains(every_events_actions_parameters, v) then table.insert( every_events_actions_parameters, v ) end
                if k ~= 1 then
                    action_lua_file:write(", \"" .. v .. "\"")
                end
            end
            action_lua_file:write("}\n") 
        end
        action_lua_file:write("local function action(arguments)\n") -- function wrapper
        
        for k, v in pairs(action_yaml_table.input_parameters) do
            action_lua_file:write("\n\tlocal " .. v .. " = " .. "arguments[\"" .. v .. "\"]")
        end

        line_num = 0

        for line in io.lines(packages_path .. "/" .. package_name .. "/actions/" .. file_name) do
            line_num = line_num + 1
            if line_num > 3 then
                action_lua_file:write(line .. "\n\t")
            end
        end

        action_lua_file:write("\nend\n\nreturn{\n\tevent = event,\n\taction = action,\n\tpriority = priority,\n\tinput_parameters = input_parameters\n}") -- ending return
        action_lua_file:close()

        local action_require_name = "tmp-lua." .. package_name .. ".actions." .. string.sub( file_name, 0, string.len( file_name ) - 4 )
        local action_require = require(action_require_name)
        
        for k, v in pairs(action_require.event) do
            local event = _G.events[v]
            if event then
                table.insert( events_actions[v], action_require )
                local action = event:addAction(
                    function(action_arguments) -- ISSUE: we have to declare here as much arguments as the action needs(maybe do a table of arguments?)
                        log.debug("[running] action " .. ansicolors('%{underline}' .. file_name) .. " with priority " .. action_yaml_table.priority )
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

-- rule interpretter
for k, package_name in pairs(fs.directory_list(packages_path)) do
    fs.create_dir("tmp-lua/" .. package_name .. "/rules/", true)
    local rules_path = packages_path .. "/".. package_name .. "/rules/"
    local rule_files = {} -- get all rules from this package
    -- Rules path is optional
    if fs.exists(rules_path) then
        rule_files = fs.get_all_files_in(rules_path)
    end
    
    for _, file_name in ipairs(rule_files) do
        if file_name ~= "lua_files/" then
            local rule_lua_path = "tmp-lua/" .. package_name .. "/" .. "rules/" .. file_name
            local rule_path = rules_path .. file_name
            log.trace("[patching] rule " .. ansicolors('%{underline}' .. file_name))

            local rule_yaml = ""
            local rule_yaml_table
            local line_num = 0
            for line in io.lines(rule_path) do
                line_num = line_num + 1        
                rule_yaml = rule_yaml .. line .. "\n" -- get only yaml lines
                if line_num == 3 then break end
            end

            rule_yaml_table = yaml.to_table(rule_yaml)

            -- rule priority cannot be higher than 100

            local priority = rule_yaml_table.priority or 1
            if priority > 100 then priority = 100 end

            --fs.copy(rule_path, rule_lua_path)
            local lua_rule = assert(io.open(rule_lua_path, "w+"))
            
            lua_rule:write("local log = require \"log\"\n")
            lua_rule:write("local utils = require \"utils\"\n")
            lua_rule:write("local priority = " .. priority)
            lua_rule:write("\nlocal events_table = { " .. "\"" .. rule_yaml_table.events_table[1] .. "\"")
            for k, v in pairs(rule_yaml_table.events_table) do
                if k ~= 1 then
                    lua_rule:write(", " .. "\"" .. v .. "\"")
                end
            end
            lua_rule:write("}")
            lua_rule:write("\nlocal input_parameter = \"" .. rule_yaml_table.input_parameter .. "\"")
            lua_rule:write("\nlocal events_parameters = { }")
            lua_rule:write("\nlocal function rule(" .. rule_yaml_table.input_parameter)
            for k, v in pairs (every_events_actions_parameters) do
                if v ~= rule_yaml_table.input_parameter then 
                    lua_rule:write(", " .. v)
                end
            end
            lua_rule:write(")")
            lua_rule:write("\n\tlog.debug('[Rule] " .. ansicolors('%{underline}' .. file_name) .. " with priority " .. priority .. " starting to evaluate')")
            lua_rule:write("\n\tlocal arguments_strings_dictionary = { }")
            lua_rule:write("\n\targuments_strings_dictionary[\"" .. rule_yaml_table.input_parameter .. "\"] = " .. rule_yaml_table.input_parameter)
            for k, v in pairs (every_events_actions_parameters) do -- matching rule arguments with action required parameters, so events_parameters["p1"] = p1
                if v ~= rule_yaml_table.input_parameter then 
                    lua_rule:write("\n\targuments_strings_dictionary[\"" .. v .. "\"] = " .. v)
                end
            end

            lua_rule:write("\n\tfor k, v in pairs(events_parameters) do")
            lua_rule:write("\n\t\tevents_parameters[k] = arguments_strings_dictionary[k]")
            lua_rule:write("\n\tend")
            lua_rule:write("\n\tif")
            line_num = 0
            for line in io.lines(rule_path) do
                line_num = line_num + 1
                if line_num > 3 then
                    lua_rule:write("\n\t" .. line)
                end
            end
            lua_rule:write("\n\tthen")
            lua_rule:write("\n\t\tlog.trace(\"Rule " .. ansicolors('%{underline}' .. file_name) .. " evaluated as TRUE \")")
            lua_rule:write("\n\t\tfor k, v in pairs(events_table) do")
            lua_rule:write("\n\t\t\tevents[v]:trigger(events_parameters)")
            lua_rule:write("\n\t\tend")
            lua_rule:write("\n\telse")
            lua_rule:write("\n\t\tlog.trace(\"Rule " .. ansicolors('%{underline}' .. file_name) .. " evaluated as FALSE \")")
            lua_rule:write("\n\tend")

            lua_rule:write("\n\tlog.debug('[Rule] " .. ansicolors('%{underline}' .. file_name) .. " evaluated succesfully')")
            lua_rule:write("\nend\n") -- bottom rule function wrapper
            
            lua_rule:write("\nlocal function get_events_parameters(events_actions)")
            lua_rule:write("\n\tfor k, v in pairs(events_table) do")
            lua_rule:write("\n\t\tfor k1, v1 in pairs(events_actions[v]) do")
            lua_rule:write("\n\t\t\tfor k2, v2 in pairs(v1.input_parameters) do")
            lua_rule:write("\n\t\t\t\tif not events_parameters[v2] then")
            lua_rule:write("\n\t\t\t\t\tevents_parameters[v2] = \" \"")
            lua_rule:write("\n\t\t\t\tend")
            lua_rule:write("\n\t\t\tend")
            lua_rule:write("\n\t\tend")
            lua_rule:write("\n\tend")
            lua_rule:write("\nend")

            lua_rule:write("\nreturn{\n\trule = rule,\n\tpriority = priority,\n\tget_events_parameters = get_events_parameters\n}") 
            lua_rule:close()

            --fs.append_to_start(rule_lua_path, "local function rule(req, events)\n\tlog.trace('rule " .. file_name .. " starting to evaluate')") -- upper rule function wrapper

        end
    end
end
---

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

            local rule_require_name = "tmp-lua." .. package_name .. ".rules." .. string.sub(file_name, 0, string.len( file_name ) - 4)
            local rule_require = require(rule_require_name)
            rule_require.get_events_parameters(events_actions) -- let the rule know which parameters it needs to its events actions
            log.debug("[loading] rule " .. ansicolors('%{underline}' .. rule_require_name))

            --table.insert(_G.rules, rule_require)
            _G.rules_priorities[rule_require_name] = rule_require.priority
        end
    end

end

for k,v in sorted_pairs(_G.rules_priorities, function(t,a,b) return t[b] < t[a] end) do
    table.insert(_G.rules, require(k))
end
--
