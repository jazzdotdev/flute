log.debug("[loading] libraries")

_G.luvent = require "Luvent"
_G.fs = require "fs"

local log = require "log"
log.outfile = "log/lighttouch"

require "table_ext"
require "string_ext"
require "underscore_alias"

log.info("[loaded] LightTouch")
