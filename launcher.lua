log.debug("[loading] libraries")

_G.luvent = require "third-party.Luvent"
_G.fs = require "fs"

local log = require "log"
fs.create_dir("log")
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
  local event_parameters = { }
  event_parameters["request"] = request
  events["incoming_request_received"]:trigger(event_parameters)
  for k, v in pairs(rules) do
    v.rule(request)
  end
   
  return response
end
