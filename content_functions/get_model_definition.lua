require "content_functions.content_base"

function content.get_model_definition (name)
  local content = fs.read_file("models/" .. name .. ".yaml")
  if not content then
    return nil, "model " .. name .. " not found"
  end
  return yaml.to_table(content)
end