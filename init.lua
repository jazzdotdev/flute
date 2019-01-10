-- Lighttouch · Torchbear App

-- this config must be before requires
local address = torchbear.settings.address or "localhost"
local port = torchbear.settings.port or "3000"
_log.info("starting web server on " .. address .. ":" .. port)
package.path = package.path..";lighttouch-base/?.lua;"
--

require "mod"
require "base"

function _G.render (file, data)
  return tera.instance:render(file, data)
end


function _G.send_request (request)

  if type(request) == "string" then
    request = {uri = request}
  end

  request.uuid = uuid.v4()
  events["outgoing_request_about_to_be_sent"]:trigger({ request = request })

  local response = client_request.send(request)
  response.uuid = uuid.v4()
  events["incoming_response_received"]:trigger({ response = response })

  return response
end



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
