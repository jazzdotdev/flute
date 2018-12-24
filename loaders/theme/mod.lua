
local themes = {}

local function load_themes(themes_dir, main_theme)

  local themes = {}

  local function load_theme (name)
    local path = themes_dir .. name .. "/"

    local files = {}
    local function scan_subdir (subdir)
      -- In here, I refer to dir as the subdirectory inside the theme directory
      -- and path to the actual location of the file

      local subpath = path .. subdir

      for entry in fs.entries(subpath) do
        local entry_path = subpath .. entry

        if fs.is_dir(entry_path) then
          -- Recurse directories
          scan_subdir(subdir .. entry .. "/")

        elseif fs.is_file(entry_path) then
          -- Add the file contents to the file list
          files[subdir .. entry] = fs.read_file(entry_path)
        end

      end
    end

    scan_subdir("")

    -- Add the file list to the global themes list
    themes[name] = files
  end

  local all_files = {}

  load_theme(main_theme)

  for theme_name, files in pairs(themes) do
    for filename, contents in pairs(files) do
      all_files[filename] = contents
    end
  end

  tera.instance:add_raw_templates(all_files)
end

return{
  load_themes = load_themes
}
