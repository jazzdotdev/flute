function actions_loader.create_actions (package_name)
    local package_path = _G.packages_path .. "/" .. package_name .. "/"
    local actions_path = package_path .. "actions/"
    local action_files = {} -- actions path is optional
    if fs.exists(actions_path) then
      action_files = fs.get_all_files_in(actions_path)
    end

    actions_loader.loop_over_actions(action_files, package_name)
end
