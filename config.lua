_G.lighttouch = {}

-- This is what's in the general section in torchbear.scl, if it's not there,
-- it isn't set by torchbear, so we have to set it manually
torchbear.settings = torchbear.settings or {}

require("third-party.read_file")

local content = fs.read_file(cwd .. "lighttouch.scl")
if not content then
  log.warn("cannot open lighttouch.scl")
  os.exit(1)
end

lighttouch.settings = scl.to_table(content)

_G.app_path = cwd
_G.db_path = cwd.."/contentdb/"
_G.log_dir = cwd.."log"
_G.content = cwd.."content/"
_G.home_store = cwd.."home-store.txt"
_G.theme = lighttouch.settings.theme
_G.themes_dir = cwd.."themes/"
