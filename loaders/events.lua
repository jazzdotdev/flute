count_lines = function(events_strings)
  local event_count = 0
  -- count the lines
  for _ in pairs(events_strings) do
    event_count = event_count + 1
  end

  return event_count
end

create_events = function(event_count, events_strings)
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

read_disabled_actions = function(package_path)
  -- read disabled actions
  local disabled_actions = { }
  for line in fs.read_lines(package_path .. "disabled_actions.txt") do
    table.insert( disabled_actions, line )
  end

  function isDisabled(action_file_name)
    for k, v in pairs(disabled_actions) do
      if action_file_name == v then
        return true
      end
    end

    return false
  end
end

for k, package_name in pairs (fs.directory_list(_G.packages_path)) do
  local events_strings = { } -- events names table
  local event_count = 0
  local package_path = _G.packages_path .. "/" .. package_name .. "/"
  log.trace("[patching] actions for package " .. ansicolors('%{underline}' .. package_name))

  -- put each line into a strings array
  for line in fs.read_lines(package_path .. "events.txt") do
    table.insert( events_strings, line )
  end

  event_count = count_lines(events_strings)

  create_events(event_count, events_strings)

  read_disabled_actions(package_path)
end

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
