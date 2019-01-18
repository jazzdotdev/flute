function rules_loader.create_rules (package_name)
  local rules_path = _G.packages_path .. "/".. package_name .. "/rules/"
  local rule_files = {} -- get all rules from this package
  -- Rules path is optional
  if fs.exists(rules_path) then
    rule_files = fs.get_all_files_in(rules_path)
  end

  log.trace("[loading] " .. ansicolors('%{underline}' .. package_name) .. " package's rules")
  for _, file_name in ipairs(rule_files) do
    if file_name ~= "lua_files/" then

      local rule_require_name = "packages." .. package_name .. ".rules." .. string.sub(file_name, 0, string.len( file_name ) - 4)
      local rule_require = require(rule_require_name)
      rule_require.get_events_parameters(_G.events_actions) -- let the rule know which parameters it needs to its events actions
      log.trace("[loaded] rule " .. ansicolors('%{underline}' .. file_name))

      --table.insert(_G.rules, rule_require)
      _G.rules_priorities[rule_require_name] = rule_require.priority
    end
  end
end
