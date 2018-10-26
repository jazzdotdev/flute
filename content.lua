
local content = {}

function content.split_header (document_text)
    local yaml_text, body = document_text:match("(.-)\n%.%.%.*\n?(.*)")
    local header = yaml.load(yaml_text)
    return header, body
end

function content.iter_files (profile, fn)
  local dir = "content/" .. profile .. "/"

  for _, file_uuid in ipairs(fs.get_all_files_in(dir)) do
    local path = dir .. file_uuid
    local file_content = fs.read_file(path)
    if not file_content then
      log.error("could not open " .. path)
    end

    local header, body = content.split_header(file_content)

    local result = fn(file_uuid, header, body)
    if result then return result end
  end
end

function content.write_file (profile, file_uuid, header, body)
  local dir = "content/" .. profile .. "/"
  os.execute("mkdir -p " .. dir)
  local path = dir .. file_uuid
  local body = yaml.dump(header) .. "\n...\n" .. (body or "")
  local file = io.open(path, "w")
  if not file then
    log.error("Could not open file", path)
  end
  file:write(body)
  file:close()
end

return content