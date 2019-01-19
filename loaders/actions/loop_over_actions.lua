function actions_loader.loop_over_actions(action_files, package_name)
    log.trace("[loading] " .. ansicolors('%{underline}' .. package_name) .. " package's actions")
    for _, file_name in ipairs(action_files) do
        local action_require_name = "packages." .. package_name .. ".actions." .. string.sub( file_name, 0, string.len( file_name ) - 4 )
        local action_require = require(action_require_name)
        actions_loader.assign_action_to_event(action_require, file_name)

        log.trace("[loaded] action " .. ansicolors('%{underline}' .. file_name))
    end
end
