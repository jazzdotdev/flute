function actions_loader.write_return (created_file, header)
    created_file:write("\n\nreturn{\n\tevent = event,\n\taction = action,\n\tpriority = priority,\n\tinput_parameters = input_parameters\n}") -- ending return
end