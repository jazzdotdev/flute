-- config
_G.app_path = fs.canonicalize(arg[1]:match(".+/")) .. "/"
_G.db_path = app_path.."/contentdb/"
_G.templates = app_path..(torchbear.settings.templates_path or "templates/**/*")
_G.log_dir = app_path.."log"
_G.content = app_path.."content/"
_G.home_store = app_path.."home-store.txt"
_G.main_theme = torchbear.settings.theme
_G.themes_dir = app_path.."themes/"
--