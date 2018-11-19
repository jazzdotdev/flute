function load_models(models_path)
    local models = fs.read_dir(models_path)
    _G.models_tables = {}
    for k, v in ipairs(models) do
        local file_path = models_path .. "/" .. v
        local model_yaml = ""
        for line in io.lines(file_path) do
            model_yaml = model_yaml .. "\n" .. line
        end
        local model_yaml_table = yaml.to_table(model_yaml)
        table.insert( models_tables, model_yaml_table)
    end
    
end

return{
    load_models = load_models
}