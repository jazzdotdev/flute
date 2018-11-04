log.debug("[loading] libraries")

math.randomseed(os.time())

_G.inspect = require "third-party.inspect"

require "third-party.base64"
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

local request_event = events["incoming_request_received"]
function request_process_action ()
    local request_uuid = uuid.v4()
    log.info("\tNew request received: " .. request_uuid)

    local request = ctx.msg
    request.path_segments = request.path:split("/")
    request.uuid = request_uuid
end
request_event:addAction(request_process_action)
request_event:setActionPriority(request_process_action, 100)

log.info("[loaded] LightTouch")

events["lighttouch_loaded"]:trigger()


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
