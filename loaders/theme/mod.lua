fs_lua = require("fs")

themes = {}
require("loaders.theme.base")
require("loaders.theme.get_parent_themes")
require("loaders.theme.find_directories")
require("loaders.theme.copy_files")
require("loaders.theme.copy_files_no_dot_checking")

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

    themes_loader.get_parent_themes(path_to_copy .. "info.yaml", theme_name)

    repeat

        themes_loader.copy_files(path_to_copy, dest_path)
        themes_loader.find_directories(path_to_copy, paths)

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
          
          themes_loader.find_directories(path_to_copy, paths)


          themes_loader.copy_files_no_dot_checking(path_to_copy, dest_path)
        end
        --
        table.remove( paths, 1 )

    until(#paths == 0) -- repeat until there were no more subdirectiories

    log.debug("[loaded] themes")
  end

  tera.instance:extend(temp_theme_path .. "/**/*")
  tera.instance:reload()
end

return{
  load_themes = load_themes
}
