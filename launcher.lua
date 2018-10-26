log.debug("[loading] libraries")

_G.luvent = require "Luvent"
_G.fs = require "fs"

local log = require "log"
log.outfile = "log/lighttouch"

require "table_ext"
require "string_ext"
require "underscore_alias"

_G.content = require "content"
_G.keys = require "keys"

require "package_loader"

log.info("[loaded] LightTouch")


-- Handler function
return function (request)

  local status = xpcall(function ()
    events["incoming_request_received"]:trigger(request)
    for k, v in pairs(rules) do
      v.get_action_parameters(events_actions)
      local rule_arguments = { }
      for k1, v1 in pairs(v.parameters) do
          if v1 == "events" then rule_arguments[v1] = events
          elseif v1 == "request" then rule_arguments[v1] = request
          -- elseif v1 == "parameter-name" then rule_arguments[v1] = parameter_value - this is how we add parameters to arugments table
          end
              
      end
    end
      v.rule(rule_arguments)
  end, err)
   
return response

end
