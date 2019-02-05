function actions_loader.custom_require(name)
    if string.match( name, "actions") then
      package.preload[name] = function(modulename)
	local created_file = io.open("module.lua", "w+")
	local modulepath = _G.app_path .. string.gsub(modulename, "%.", "/")
        local path = "/"
        local filename = string.gsub(path, "%?", modulepath)
        local file = io.open(filename, "rb")
        if file then
          local header = actions_loader.extract_header(modulepath)
  
          actions_loader.write_events(created_file, header)
          actions_loader.set_priority(created_file, header)
          actions_loader.write_input_parameters(created_file, header)
          actions_loader.write_function(created_file, header, modulepath)
          actions_loader.write_return(created_file, header)
  
          created_file:close()
          -- Compile and return the module
          local to_compile = io.open("module.lua", "rb")
          return assert(load(assert(to_compile:read("*a")), modulepath))
        end
      end
      return require(name)
    else
      return default_package_searchers2(name)
    end
  end
