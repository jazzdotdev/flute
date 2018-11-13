function loader(modulename) 
    local created_file = io.open("module.lua", "w+")
    local modulepath = string.gsub(modulename, "%.", "/")
    local path = "/"
    local filename = string.gsub(path, "%?", modulepath)
    local file = io.open(filename, "rb")
    if file then
        local rule_yaml = ""
        local rule_yaml_table
        local line_num = 0
        for line in io.lines(modulepath .. ".lua") do
            line_num = line_num + 1        
            rule_yaml = rule_yaml .. line .. "\n" -- get only yaml lines
            if line_num == 3 then break end
        end

        rule_yaml_table = yaml.to_table(rule_yaml)

        local priority = rule_yaml_table.priority or 1
        if priority > 100 then priority = 100 end

        created_file:write("local priority = " .. priority)
        created_file:write("\nlocal events_table = { " .. "\"" .. rule_yaml_table.events_table[1] .. "\"")
        for k, v in pairs(rule_yaml_table.events_table) do
            if k ~= 1 then
                created_file:write(", " .. "\"" .. v .. "\"")
            end
        end
        created_file:write("}")
        created_file:write("\nlocal input_parameter = \"" .. rule_yaml_table.input_parameter .. "\"")
        created_file:write("\nlocal events_parameters = { }")
        created_file:write("\nlocal function rule(" .. rule_yaml_table.input_parameter)
        for k, v in pairs (_G.every_events_actions_parameters) do
            if v ~= rule_yaml_table.input_parameter then 
                created_file:write(", " .. v)
            end
        end
        created_file:write(")")
        created_file:write("\n\tlog.debug('[Rule] " .. _G.ansicolors('%{underline}' .. modulename) .. " with priority " .. priority .. " starting to evaluate')")
        created_file:write("\n\tlocal arguments_strings_dictionary = { }")
        created_file:write("\n\targuments_strings_dictionary[\"" .. rule_yaml_table.input_parameter .. "\"] = " .. rule_yaml_table.input_parameter)
        for k, v in pairs (_G.every_events_actions_parameters) do -- matching rule arguments with action required parameters, so events_parameters["p1"] = p1
            if v ~= rule_yaml_table.input_parameter then 
                created_file:write("\n\targuments_strings_dictionary[\"" .. v .. "\"] = " .. v)
            end
        end

        created_file:write("\n\tfor k, v in pairs(events_parameters) do")
        created_file:write("\n\t\tevents_parameters[k] = arguments_strings_dictionary[k]")
        created_file:write("\n\tend")
        created_file:write("\n\tif")
        line_num = 0
        for line in io.lines(modulepath .. ".lua") do
            line_num = line_num + 1
            if line_num > 3 then
                created_file:write("\n\t" .. line)
            end
        end

        created_file:write("\n\tthen")
        created_file:write("\n\t\tlog.trace(\"Rule " .. _G.ansicolors('%{underline}' .. modulename) .. " evaluated as TRUE \")")
        created_file:write("\n\t\tfor k, v in pairs(events_table) do")
        created_file:write("\n\t\t\tevents[v]:trigger(events_parameters)")
        created_file:write("\n\t\tend")
        created_file:write("\n\telse")
        created_file:write("\n\t\tlog.trace(\"Rule " .. _G.ansicolors('%{underline}' .. modulename) .. " evaluated as FALSE \")")
        created_file:write("\n\tend")

        created_file:write("\n\tlog.debug('[Rule] " .. _G.ansicolors('%{underline}' .. modulename) .. " evaluated succesfully')")
        created_file:write("\nend\n") -- bottom rule function wrapper
        
        created_file:write("\nlocal function get_events_parameters(events_actions)")
        created_file:write("\n\tfor k, v in pairs(events_table) do")
        created_file:write("\n\t\tfor k1, v1 in pairs(events_actions[v]) do")
        created_file:write("\n\t\t\tfor k2, v2 in pairs(v1.input_parameters) do")
        created_file:write("\n\t\t\t\tif not events_parameters[v2] then")
        created_file:write("\n\t\t\t\t\tevents_parameters[v2] = \" \"")
        created_file:write("\n\t\t\t\tend")
        created_file:write("\n\t\t\tend")
        created_file:write("\n\t\tend")
        created_file:write("\n\tend")
        created_file:write("\nend")

        created_file:write("\nreturn{\n\trule = rule,\n\tpriority = priority,\n\tget_events_parameters = get_events_parameters\n}") 
        created_file:close()
        -- Compile and return the module
        local to_compile = io.open("module.lua", "rb")
        return assert(load(assert(to_compile:read("*a")), modulepath))
    end
end

return{
    loader = loader
}