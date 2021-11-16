#!/usr/bin/env torchbear
-- Lighttouch · Torchbear App

_G.cwd = fs.canonicalize(env.current_dir()) .. "/"

require "config"

_G.log = require "third-party.log"
log.level = settings.log_level or "info"

-- this config must be before requires
package.path = package.path ..";" .. cwd .. "?.lua;"
--

-- TODO: refactor out into a library (and make it prettier)
local _req = require
function require (module_name)

  local is_new = package.loaded[module_name] == nil
  
  local mod = _req(module_name)

  if is_new and type(mod) == "function" then
    log.debug("Patched module function " .. module_name)
    local _mod = mod
    function mod (...)
      local args_str = table.concat({...}, ", ")
      log.trace("[function] " .. module_name .. "(" .. args_str .. ")")

      local function fn (...) return {...} end
      local result = fn(_mod(...))

      local rets_str = table.concat({rets_tbl}, ", ")
      log.trace("[function] " .. module_name .. " returned " .. rets_str)
      return table.unpack(result)
    end
    package.loaded[module_name] = mod
  end

  return mod
end

require "mod"
require "base"

local address = torchbear.settings and torchbear.settings.address or "localhost"
local port = torchbear.settings and torchbear.settings.port or "3000"
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
