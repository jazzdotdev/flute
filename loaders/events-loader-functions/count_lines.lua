function events_loader.count_lines (events_strings)
    local event_count = 0
    -- count the lines
    for _ in pairs(events_strings) do
      event_count = event_count + 1
    end
  
    return event_count
end