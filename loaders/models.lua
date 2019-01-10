_G.models = {}

-- Walk through all packages' directories
for _, package_name in ipairs(fs.directory_list(_G.packages_path)) do

  local models_path = _G.packages_path .. "/".. package_name .. "/models/"
  local model_files = {}

  -- The models directory is optional
  if fs.exists(models_path) then
    model_files = fs.read_dir(models_path)
  end

  -- Walk through files in the models directory
  for _, filename in ipairs(model_files) do
    log.trace("[loading] model at " .. ansicolors('%{underline}' .. filename))

    -- Get the model name from the file name (remove irectories and extension)
    local name = filename:match("(.+)%.scl$")
    local file_path = models_path .. filename
    local model_scl = fs.read_file(file_path)
    local model_table = scl.to_table(model_scl)
    models[name] = model_table
  end

end

return models