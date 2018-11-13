function loader(modulename)
    local created_file = io.open("module.lua", "w+")
    local modulepath = string.gsub(modulename, "%.", "/")
    local path = "/"
    local filename = string.gsub(path, "%?", modulepath)
    local file = io.open(filename, "rb")
    if file then

        local action_yaml = ""
        local line_num = 0
        for line in io.lines(modulepath .. ".lua") do
            line_num = line_num + 1        
            action_yaml = action_yaml .. line .. "\n" -- get only yaml lines
            if line_num == 3 then break end
        end
        local action_yaml_table = yaml.to_table(action_yaml) -- decode yaml to lua table
        created_file:write("local event = { \"" .. action_yaml_table.event[1] .. "\"") -- put values from yaml in lua form

        for _, yaml_event in ipairs(action_yaml_table.event) do
            if yaml_event ~= action_yaml_table.event[1] then 
                created_file:write(', "' .. yaml_event .. '"') -- put all events to 'local event = { }'
            end
        end

        created_file:write(" }")
        created_file:write("\nlocal priority = " .. action_yaml_table.priority .. " \n\n")
        if action_yaml_table.input_parameters[1] then
            created_file:write("local input_parameters = { " .. "\"" .. action_yaml_table.input_parameters[1] .. "\"")
            for k, v in pairs(action_yaml_table.input_parameters) do
                if not table.contains(_G.every_events_actions_parameters, v) then table.insert( _G.every_events_actions_parameters, v ) end
                if k ~= 1 then
                    created_file:write(", \"" .. v .. "\"")
                end
            end
            created_file:write("}\n") 
        end
        created_file:write("local function action(arguments)\n") -- function wrapper
        
        for k, v in pairs(action_yaml_table.input_parameters) do
            created_file:write("\n\tlocal " .. v .. " = " .. "arguments[\"" .. v .. "\"]")
        end
        line_num = 0

        for line in io.lines(modulepath .. ".lua") do
            line_num = line_num + 1
            if line_num > 3 then
                created_file:write(line .. "\n\t")
            end
        end
        created_file:write("\nend\n\nreturn{\n\tevent = event,\n\taction = action,\n\tpriority = priority,\n\tinput_parameters = input_parameters\n}") -- ending return
        created_file:close()
        -- Compile and return the module
        local to_compile = io.open("module.lua", "rb")
        return assert(load(assert(to_compile:read("*a")), modulepath))
    end
end

return{
    loader = loader
}