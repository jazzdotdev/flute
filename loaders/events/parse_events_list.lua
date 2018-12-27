function events_loader.parse_events_list (package_name)
    local events_strings = { } -- events names table
    local package_path = _G.packages_path .. "/" .. package_name .. "/"

    -- put each line into a strings array
    for line in fs.read_lines(package_path .. "events.txt") do
        table.insert( events_strings, line )
    end

    return events_strings
end