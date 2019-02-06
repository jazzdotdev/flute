_G.cwd = fs.canonicalize(env.current_dir()) .. "/"
_G.db_path = cwd.."/contentdb/"
_G.log_dir = cwd.."log"
_G.content = cwd.."content/"
_G.home_store = cwd.."home-store.txt"
_G.theme = lighttouch.settings.theme
_G.themes_dir = cwd.."themes/"
