log.debug("[loading] libraries")

_G.luvent = require "third-party.Luvent"
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
    --events["incoming_request_received"]:trigger(request)
    for k, v in pairs(rules) do
      -- log.trace("about to call get_actions_params")
      v.get_action_parameters(events_actions)
      log.trace("after get action parameters")
      local rule_arguments = { }
      for k1, v1 in pairs(v.parameters) do
        print(v1)
          if v1 == "events" then rule_arguments[v1] = events
          elseif v1 == "request" then rule_arguments[v1] = request
          -- elseif v1 == "parameter-name" then rule_arguments[v1] = parameter_value - this is how we add parameters to arugments table
          end
              
      end
      log.trace("about to invoke the rule")
      v.rule(rule_arguments)
    end
  end, err)
   
return response

end
