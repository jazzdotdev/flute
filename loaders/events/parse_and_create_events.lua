function events_loader.parse_and_create_events(package_name)

  local events_strings = events_loader.parse_events_list(package_name)
  events_loader.create_events( #events_strings, events_strings )
  
end
