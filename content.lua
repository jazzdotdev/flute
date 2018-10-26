
local content = {}

local split_yaml_header = (require "helpers").split_yaml_header

function content.iter_files (profile, fn)
  local dir = "content/" .. profile .. "/"

  for _, file_uuid in ipairs(fs.get_all_files_in(dir)) do
    local path = dir .. file_uuid
    local file_content = fs.read_file(path)
    if not file_content then
      log.error("could not open " .. path)
    end

    local header, content = split_yaml_header(file_content)

    local result = fn(file_uuid, header, content)
    if result then return result end
  end
end

function content.write_file (profile, file_uuid, header, body)
  local dir = "content/" .. profile .. "/"
  os.execute("mkdir -p " .. dir)
  local path = dir .. file_uuid
  local content = yaml.dump(header) .. "\n...\n" .. (body or "")
  local file = io.open(path, "w")
  if not file then
    log.error("Could not open file", path)
  end
  file:write(content)
  file:close()
end

return content