function actions_loader.assign_action_to_event(action, file_name)
  for k, v in pairs(action.event) do
    local event = _G.events[v]
    if event then
      table.insert( _G.events_actions[v], action )
      local event_action = event:addAction(
      function(input_parameters)
        log.debug("[running] action " .. ansicolors('%{underline}' .. file_name) .. " with priority " .. action.priority )
        -- TODO: figure out what to do if more than one responses are returned
        possibleResponse = action.action(input_parameters)
        if possibleResponse ~= nil then
          if possibleResponse.body ~= nil then
            _G.lighttouch_response = possibleResponse
            if events["outgoing_response_about_to_be_sent"] then
              events["outgoing_response_about_to_be_sent"]:trigger({response = possibleResponse})
            end
          end
        end
        log.debug("[completed] action " .. ansicolors('%{underline}' .. file_name) )
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