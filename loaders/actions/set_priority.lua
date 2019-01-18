function actions_loader.set_priority (created_file, header)
    created_file:write("\nlocal priority = " .. header.priority .. " \n\n")
end
