function actions_loader.assign_action_to_event(action_require, file_name)
    for k, v in pairs(action_require.event) do
        local event = _G.events[v]
        if event then
          table.insert( _G.events_actions[v], action_require )
          local action = event:addAction(
            function(action_arguments)
              log.debug("[running] action " .. ansicolors('%{underline}' .. file_name) .. " with priority " .. action_require.priority )
              -- TODO: figure out what to do if more than one responses are returned
              possibleResponse = action_require.action(action_arguments)
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
          event:setActionPriority(action, action_require.priority)
          
          --if isDisabled(file_name) then
          --  event:disableAction(action)
          --end
        else
          log.error("event " .. v .. " doesn't exist")
        end
      end
end