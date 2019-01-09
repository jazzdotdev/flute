function actions_loader.create_actions (package_name)
    local start_time = os.clock()
    local package_path = _G.packages_path .. "/" .. package_name .. "/"
    local actions_path = package_path .. "actions/"
    local action_files = {} -- actions path is optional
    if fs.exists(actions_path) then
      action_files = fs.get_all_files_in(actions_path)
    end

    actions_loader.loop_over_actions(action_files, package_name)
    local elapsed = (os.clock() - start_time) * 1000
    log.trace("Loaded actions for " .. package_name .. " in " .. elapsed .. " milliseconds")
end
