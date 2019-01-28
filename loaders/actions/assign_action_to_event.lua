function actions_loader.assign_action_to_event(action, file_name)
  for k, v in pairs(action.event) do
    local event = _G.events[v]
    if event then
      table.insert( _G.events_actions[v], action )
      local event_action = event:addAction(
      function(input_parameters)
        log.trace("[running] action " .. ansicolors('%{underline}' .. file_name) .. " with priority " .. action.priority )
        local response = action.action(input_parameters)
        -- Only the first generated response is sent
        if response and _G.lighttouch_response == nil then
          _G.lighttouch_response = response
        end
        log.trace("[completed] action " .. ansicolors('%{underline}' .. file_name) )
      end
      )
      event:setActionPriority(event_action, action.priority)
      if events_loader.isDisabled(file_name) then
        event:disableAction(event_action)
      end
    else
      log.error("event " .. v .. " doesn't exist")
    end
  end
end
