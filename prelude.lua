log.debug("[loading] libraries")
_G.utils = require "utils"
_G.luvent = require "Luvent"
_G.fs = require "fs"

local log = require "log"

require "table_ext"
require "string_ext"
require "underscore_alias"

log.trace("[loaded] LightTouch")
