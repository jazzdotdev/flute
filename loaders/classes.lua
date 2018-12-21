
local class_dir = "temp-theme/_class/"
require("loader.class-loader-functions.base")
require("loader.class-loader-functions.load_class_file")

function load_classes ()
  log.trace("Loading classes in theme")
  if fs.is_dir(class_dir) then
    each(fs.get_all_files_in(class_dir), class_loader.load_class_file)
  end
end

return {
  load_classes = load_classes
}