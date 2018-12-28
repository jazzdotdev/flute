-- Lighttouch · Torchbear App

local address = torchbear.settings.address or "localhost"
local host = torchbear.settings.host or "3000"
_log.info("starting web server on " .. address .. ":" .. host)

package.path = package.path..";lighttouch-base/?.lua;"

_log.debug("[loading] libraries")

math.randomseed(os.time())

tera.instance = tera.new(torchbear.settings.templates_path or "templates/**/*")

function _G.render (file, data)
  return tera.instance:render(file, data)
end

_G.log = require "third-party.log"
_G.inspect = require "third-party.inspect"
_G.luvent = require "third-party.Luvent"

require "third-party.base64"
_G.fs = require "fs"

log.level = torchbear.settings.log_level or "info"

fs.create_dir("log")
log.outfile = "log/lighttouch"

require "table_ext"
require "string_ext"
require "underscore_alias"

_G.content = require "content.mod"
_G.keys = require "keys.mod"

-- Get home-store uuid
local home_store = fs.read_file("home-store.txt")
if not home_store then
  home_store = uuid.v4()
  log.info("No home content store found. Creating new one with uuid " .. home_store)
  local file = io.open("home-store.txt", "w")
  if not file then
    log.error("Could not open home-store.txt")
  end
  file:write(home_store)
  file:close()
end
content.home = home_store

require "loaders.package"

local theme_loader = require "loaders.themes.base"
local class_loader = require "loaders.classes"


-- Move this to another file, in loaders maybe

if torchbear.settings.theme then
  theme_loader.load_themes("themes/", torchbear.settings.theme)
  class_loader.load_classes()
end

local incoming_request_event = events["incoming_request_received"]
local function request_process_action (arguments)
    local request_uuid = uuid.v4()
    log.info("\tNew request received: " .. request_uuid)

    local request = arguments.request
    request.path_segments = request.path:split("/")
    request.uuid = request_uuid
end
incoming_request_event:addAction(request_process_action)
incoming_request_event:setActionPriority(request_process_action, 100)

local outgoing_response_event = events["outgoing_response_about_to_be_sent"]
local function response_process_action (arguments)
    local response = arguments.response
    local response_uuid = uuid.v4()
    response.uuid = response_uuid
    log.info("\tSending response: " .. response_uuid)
end
outgoing_response_event:addAction(response_process_action)
outgoing_response_event:setActionPriority(response_process_action, 100)

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

log.info("[loaded] LightTouch")

events["lighttouch_loaded"]:trigger()


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
