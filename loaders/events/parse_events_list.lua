function events_loader.parse_events_list (package_name)
    local events_strings = { } -- events names table
    local event_count = 0
    local package_path = _G.packages_path .. "/" .. package_name .. "/"

    -- put each line into a strings array
    for line in fs.read_lines(package_path .. "events.txt") do
        table.insert( events_strings, line )
    end

    event_count = events_loader.count_lines(events_strings)

    -- events_loader.create_events(event_count, events_strings)

    -- events_loader.read_disabled_actions(package_path)
    return events_strings
end