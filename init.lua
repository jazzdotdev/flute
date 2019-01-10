-- Lighttouch · Torchbear App

-- this config must be before requires
local address = torchbear.settings.address or "localhost"
local port = torchbear.settings.port or "3000"
_log.info("starting web server on " .. address .. ":" .. port)
package.path = package.path..";lighttouch-base/?.lua;"
--

require "mod"
require "base"

-- Handler function
return function (request)
  _G.lighttouch_response = nil

  local event_parameters = { }
  event_parameters["request"] = request
  events["incoming_request_received"]:trigger(event_parameters)
  for k, v in pairs(rules) do
    v.rule(request)
  end

  return lighttouch_response
end
