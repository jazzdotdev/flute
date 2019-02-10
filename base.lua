log.trace("[loading] libraries")

lua_math.randomseed(os.time())

tera.instance = tera.new(settings.templates_path or "templates/**/*")

log.level = settings.log_level or "info"

fs.create_dir(_G.log_dir)
log.outfile = _G.log_dir.."/lighttouch"

-- Get home-store uuid
local home_store = fs.read_file(_G.home_store)
if not home_store then
  home_store = uuid.v4()
  log.info("No home content store found. Creating new one with uuid " .. home_store)
  local file = io.open(_G.home_store, "w")
  if not file then
    log.error("Could not open home-store.txt")
  end
  file:write(home_store)
  file:close()
  fs.create_dir(_G.content .. home_store, true)
end
contentdb.home = home_store

contentdb.scan_stores()

if settings.theme then
  theme_loader.load_themes(_G.themes_dir, settings.theme)
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

log.info("[loaded] LightTouch")
events["lighttouch_loaded"]:trigger()
