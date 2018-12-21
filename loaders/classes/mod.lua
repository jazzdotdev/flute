
local class_dir = "temp-theme/_class/"
require("loader.classes.base")
require("loader.classes.load_class_file")

function load_classes ()
  log.trace("Loading classes in theme")
  if fs.is_dir(class_dir) then
    each(fs.get_all_files_in(class_dir), class_loader.load_class_file)
  end
end

return {
  load_classes = load_classes
}