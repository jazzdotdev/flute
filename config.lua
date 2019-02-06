
require("third-party.read_file")

local content = fs.read_file(cwd .. "lighttouch.scl")
if not content then
  _log.error("cannot open lighttouch.scl")
  os.exit(1)
end

_G.settings = scl.to_table(content)

_G.app_path = cwd
_G.db_path = cwd.."/contentdb/"
_G.log_dir = cwd.."log"
_G.content = cwd.."content/"
_G.home_store = cwd.."home-store.txt"
_G.theme = settings.theme
_G.themes_dir = cwd.."themes/"
