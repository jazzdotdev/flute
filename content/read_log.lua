function contentdb.read_log (log_uuid)
  -- It's getting just the request logs, it should read all logs but this
  -- function is not completely thought trough yet
  local dir = "log/incoming-request/"

  for _, file_uuid in ipairs(fs.get_all_files_in(dir)) do
    local path = dir .. file_uuid
    local file_content = fs.read_file(path)
    if not file_content then
      error("could not open " .. path)
    end

    return scl.to_table(file_content)
  end
end
