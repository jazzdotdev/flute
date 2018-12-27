function actions_loader.loop_over_actions(action_files, package_name)
    for _, file_name in ipairs(action_files) do
        log.trace("[patching] action " .. ansicolors('%{underline}' .. file_name))

        local action_require_name = "packages." .. package_name .. ".actions." .. string.sub( file_name, 0, string.len( file_name ) - 4 )
        local action_require = require(action_require_name)
        actions_loader.assign_action_to_event(action_require, file_name)
    end
    log.trace("[patched] actions for package " .. ansicolors('%{underline}' .. package_name))
end