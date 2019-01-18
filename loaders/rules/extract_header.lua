function rules_loader.extract_header (modulepath)
  local header = ""
  local line_num = 0
  for line in io.lines(modulepath .. ".lua") do
    line_num = line_num + 1
    header = header .. line .. "\n" -- get only first 3 lines
    if line_num == 3 then break end
  end

  return scl.to_table(header) -- decode scl string into a lua table
end
