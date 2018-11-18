local fs_lua = require("fs")

-- function string:split(sep) -- string split function to extracting package name
--     local sep, fields = sep or ":", {}
--     local pattern = string.format("([^%s]+)", sep)
--     self:gsub(pattern, function(c) fields[#fields+1] = c end)
--     return fields
-- end

-- local function file_exist(path)
--     local f = io.open(path, "r")
--     if f ~= nil then
--         io.close(f)
--         return true
--     else
--         return false
--     end
-- end

local function load_themes(themes_dir, initial_name)

    os.execute("mkdir -p temp-theme") -- autocreate tmp-thme for now

    local themes_dir_path = themes_dir -- for now put it manually here
    local initial_theme_name = initial_name -- put the initial name here
    local temp_theme_path = "temp-theme" -- put the path for temp theme dir here
    local themes = {}

    local initial_theme_path = themes_dir_path .. "/" .. initial_theme_name
    local initial_config_path = initial_theme_path .. "/" .. "info.yaml" -- open info.yaml from initial
    table.insert( themes, initial_theme_name )
    
    local initial_yaml = ""
    local line_num = 0

    for line in io.lines(initial_config_path) do -- get the parent themes info from config.yaml
        line_num = line_num + 1
        initial_yaml = initial_yaml .. line
    end

    local initial_yaml_table = yaml.to_table(initial_yaml) -- translate yaml to lua table

    
    -- for k, v in ipairs(initial_yaml_table.parents) do
    --     print("[DEBUG] Found theme " .. v)
    --     table.insert( themes, v ) -- put the themes names into table
    -- end

    for k, v in ipairs(themes) do -- copy files to tmp-theme from each theme from intital-theme/config.yaml

        local theme_name = v
        local path_to_copy = themes_dir_path .. "/" .. theme_name .. "/"
        local dest_path = temp_theme_path .. "/"
        local paths = {}

        repeat

            local files_in_dir = fs.read_dir(path_to_copy) -- get files from theme main or theme subdirectory
            for _, file_name in ipairs(files_in_dir) do
                local file_path = path_to_copy .. file_name
                local dest_of_file = dest_path .. file_name
                if not fs.exists(dest_of_file) and string.sub( file_name, -1 ) ~= '/' then -- if file not exist and file is not directory
                    fs_lua.copy(file_path, dest_of_file)
                end
            end
                dirs = fs_lua.directory_list(path_to_copy) -- get list of directories in current location

                for k, v in pairs(dirs) do

                    table.insert( paths, v)
                end
                
                -- update paths
                if paths[1] ~= nil then
                    
                    path_to_copy = paths[1]
                    dest_path = temp_theme_path
                    local path_modules = path_to_copy:split("/")
                    table.remove( path_modules, 1 )
                    table.remove( path_modules, 1 )
                    -- deleting the first two modules so f.e from themes/fixed-sidebar/templates we have /templates
                    for k, v in pairs(path_modules) do
                        dest_path = dest_path .. "/" .. v
                    end
                    dest_path = dest_path .. "/" -- dest path is like temp-theme/templates

                    os.execute("mkdir -p " .. dest_path) -- create dir in temp-theme/
                end
                --
                table.remove( paths, 1 ) 

        until(#paths == 0) -- repeat until there were no more subdirectiories

        log.debug("Themes loop ended")
    end
    
end    

return{
    load_themes = load_themes
}

