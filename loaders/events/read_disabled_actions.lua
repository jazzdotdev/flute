function events_loader.read_disabled_actions (package_path)
  local disabled_actions = { }
  for line in fs.read_lines(package_path .. "disabled_actions.txt") do
    table.insert( disabled_actions, line )
  end

  -- if action file name is in disabled_actions table, return true
  function events_loader.isDisabled(action_file_name)
    for k, v in pairs(disabled_actions) do
      if action_file_name == v then
        return true
      end
    end

    return false
  end
end