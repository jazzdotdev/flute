local fs_lua = require("fs")

local themes = {}
local function load_themes(themes_dir, initial_name)

  local themes_dir_path = themes_dir -- take themes dir from function arguments
  local initial_theme_name = initial_name -- take initial theme name from function arguments
  local temp_theme_path = "temp-theme" -- path for temp-theme

  os.execute("rm -r " .. temp_theme_path) -- remove old temp-theme
  fs.create_dir(temp_theme_path) -- create new temp-theme dir

  local initial_theme_path = themes_dir_path .. "/" .. initial_theme_name
  local initial_config_path = initial_theme_path .. "/" .. "info.yaml" -- open info.yaml from initial
  table.insert( themes, initial_theme_name )

  for k, v in ipairs(themes) do -- copy files to temp-theme from each parent of each theme 
    local theme_yaml = ""
    local theme_name = v
    local path_to_copy = themes_dir_path .. "/" .. theme_name .. "/"
    local dest_path = temp_theme_path .. "/"
    local paths = {}

    get_parent_themes(path_to_copy .. "info.yaml", theme_name)

    repeat

        copy_files(path_to_copy, dest_path)
        find_directories(path_to_copy, paths)

        -- update paths
        if paths[1] ~= nil then
          path_to_copy = paths[1] .. "/"
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
          
          find_directories(path_to_copy, paths)


          copy_files_no_dot_checking(path_to_copy, dest_path)
        end
        --
        table.remove( paths, 1 )

    until(#paths == 0) -- repeat until there were no more subdirectiories

    log.debug("[loaded] themes")
  end

  tera.instance:extend(temp_theme_path .. "/**/*")
  tera.instance:reload()
end

function get_parent_themes(config_path, theme_name)

  local theme_yaml = ""
  for line in io.lines(config_path) do
    theme_yaml = theme_yaml .. "\n" .. line -- get yaml from one of parent themes
  end

  local theme_yaml_table = yaml.to_table(theme_yaml)
  
  if theme_yaml_table.parent ~= nil then
    for k1, v1 in ipairs(theme_yaml_table.parent) do -- adding parents of each theme to themes to load
      log.debug("Found theme " .. v1 .. " as parent for " .. theme_name)
      table.insert(themes, v1)
    end
  end
end

function copy_files(path_to_copy, dest_path)

  log.trace("running: " .. debug.getinfo(1, "S").source .. ": " .. debug.getinfo(1, "Sl").currentline .. " - " .. "Path to copy: " .. path_to_copy)
  local files_in_dir = fs.read_dir(path_to_copy) -- get files from theme main or theme subdirectory
  for _, file_name in ipairs(files_in_dir) do
    local file_path = path_to_copy .. file_name
    local dest_of_file = dest_path .. file_name
    log.trace("running: " .. debug.getinfo(1, "S").source .. ": " .. debug.getinfo(1, "Sl").currentline .. " - " .. "Copy: " .. file_path .. " -> " .. dest_of_file)

    -- to avoid errors with .git and hidden folders 
    local aproved = true --the element is aproved to be added 
    if string.find(dest_path, "/.") ~= nil then -- if the element folder name starts with a dot ".git"
      aproved = false -- the element is not aproved then must be ignored
    end
    --end of checking 

    if not fs.exists(dest_of_file) and fs.is_file(file_path) and aproved then -- if file not exist and file is not directory and file not aproved
      fs_lua.copy(file_path, dest_of_file)
    end
  end

end

function find_directories(path_to_copy, paths)

  dirs = fs_lua.directory_list(path_to_copy) -- get list of directories in current location

  for k, v in pairs(dirs) do

    table.insert( paths, path_to_copy .. v)
    log.trace("running: " .. debug.getinfo(1, "S").source .. ": " .. debug.getinfo(1, "Sl").currentline .. " - " .. "Found directory: " .. v)
  end

end

function copy_files_no_dot_checking(path_to_copy, dest_path)

  for _, filename in ipairs(fs.get_all_files_in(path_to_copy)) do
    local src = path_to_copy .. filename
    local dst = dest_path .. filename
    fs_lua.copy(src, dst)
  end

end

return{
  load_themes = load_themes
}
