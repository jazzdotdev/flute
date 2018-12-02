function create_base_events()
    events["lighttouch_loaded"] = luvent.newEvent()
    _G.events_actions["lighttouch_loaded"] = { }

    events["incoming_request_received"] = luvent.newEvent()
    _G.events_actions["incoming_request_received"] = { }

    events["outgoing_response_about_to_be_sent"] = luvent.newEvent()
    _G.events_actions["outgoing_response_about_to_be_sent"] = { }

    events["document_created"] = luvent.newEvent()
    _G.events_actions["document_created"] = { }

    events["incoming_response_received"] = luvent.newEvent()
    _G.events_actions["incoming_response_received"] = { }

    events["outgoing_request_about_to_be_sent"] = luvent.newEvent()
    _G.events_actions["outgoing_request_about_to_be_sent"] = { }
end

function count_and_create_events(package_path)
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
            _G.events_actions[name] = { } -- create table of actions for that event
        end
        event:addAction(function ()
            log.debug("[triggering] event"  .. ansicolors('%{underline}' .. name) )
        end)
    end
end

function disabled_actions(package_path)
    -- read disabled actions
    local disabled_actions_table = { }
    for line in fs.read_lines(package_path .. "disabled_actions.txt") do
        table.insert( disabled_actions, line )
    end
    ---
    return disabled_actions_table
end

create_base_events()

for k, package_name in pairs (fs.directory_list(_G.packages_path)) do
    local package_path = _G.packages_path .. "/" .. package_name .. "/"

    log.trace("[patching] actions for package " .. ansicolors('%{underline}' .. package_name))

    count_and_create_events(package_path)

    function isDisabled(action_file_name)
        for k, v in pairs(disabled_actions(package_path)) do
            if action_file_name == v then 
                return true 
            end
        end
    
        return false
    end
end