function load_models(models_path)
    local files = fs.read_dir(models_path)
    _G.models = {}
    for _, filename in ipairs(files) do
        local name = filename:match("(.+)%.yaml")
        local file_path = models_path .. "/" .. filename
        local model_yaml = fs.read_file(file_path)
        local model_yaml_table = yaml.to_table(model_yaml)
        models[name] = model_yaml_table
    end
    
end

return { load_models = load_models }