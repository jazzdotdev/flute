
content = {
  stores = {
    home = "content/home/"
  }
}

fs.create_dir("content/home", true)

-- Methods for the model class
local model_metatable = {}
model_metatable.__index = model_metatable
function model_metatable:validate (object)
  for name, validator in pairs(self.fields) do
    local result, err = validator(object[name])
    if not result then
      return result, name .. ": " .. err
    end
  end
  return true
end

-- Add all directories in content to the stores table
for entry in fs.entries("content/") do
  if fs.metadata("content/" .. entry).type == "directory" then
    content.stores[entry] = "content/" .. entry .. "/"
  end
end




-- Sobmodules

require "content.add_document_to_index"
require "content.setup_schema"
require "content.setup_index"
require "content.query"

require "content.split_header"
require "content.get_model_definition"
require "content.get_validator"
require "content.validate_document"

require "content.read_document"
require "content.documents"
require "content.walk_documents"
require "content.write_file"

return content