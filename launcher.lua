log.debug("[loading] libraries")

math.randomseed(os.time())

_G.inspect = require "third-party.inspect"

-- https://github.com/kyren/rlua/issues/99
function math.pow (b, n)
  local r = 1
  for _ = 1, n do
    r = r*b
  end
  return r
end

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

log.info("[loaded] LightTouch")


-- Handler function
return function (request)
  events["incoming_request_received"]:trigger(request)
  for k, v in pairs(rules) do
    v.rule(request, events)
  end
   
  return response
end
