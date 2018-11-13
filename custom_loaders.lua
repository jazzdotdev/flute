local action_loader = require "action_loader"
local rule_loader = require "rule_loader"
local default_package_searchers2 = package.searchers[2]
package.searchers[2] = function(name) 
    if string.match( name, "actions") then
        package.preload[name] = action_loader.loader
        return require(name)
    elseif string.match( name, "rules") then
        package.preload[name] = rule_loader.loader
        return require(name)
    else
        print(name) -- else default return so it won't change code of other modules (f.e. log or ansicolors)
        return default_package_searchers2(name)
    end
end
--