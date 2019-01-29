#!/usr/bin/env torchbear
-- Lighttouch · Torchbear App

-- this config must be before requires
local address = torchbear.settings.address or "localhost"
local port = torchbear.settings.port or "3000"
package.path = package.path..";lighttouch-base/?.lua;"
--

require "mod"
require "base"

log.info("[starting] web server on " .. address .. ":" .. port)

-- Handler function
return function (request)
  _G.lighttouch_response = nil

  local event_parameters = { }
  event_parameters["request"] = request
  events["incoming_request_received"]:trigger(event_parameters)
  for k, v in pairs(rules) do
    v.rule(request)
  end

  if lighttouch_response then
    events["outgoing_response_about_to_be_sent"]:trigger({
      response = lighttouch_response
    })
  end

  return lighttouch_response
end
