function actions_loader.create_actions (package_name)
    local package_path = _G.packages_path .. "/" .. package_name .. "/"
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