
local address = torchbear.settings.address or "localhost"
local host = torchbear.settings.host or "3000"
log.info("started web server on " .. address .. ":" .. host)

package.path = package.path..";lighttouch-base/?.lua;"

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
local function request_process_action ()
    local request_uuid = uuid.v4()
    log.info("\tNew request received: " .. request_uuid)

    local request = ctx.msg
    request.path_segments = request.path:split("/")
    request.uuid = request_uuid
end
request_event:addAction(request_process_action)
request_event:setActionPriority(request_process_action, 100)

function _G.send_request (request)

  if type(request) == "string" then
    request = {uri = request}
  end

  events["outgoing_request_about_to_be_sent"]:trigger({ request = request })

  local response = client_request.send(request)

  events["incoming_response_received"]:trigger({ response = response })
  
end

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
