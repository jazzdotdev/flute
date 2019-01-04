classes_loader = { }

require("loaders.classes.mod")

themes_loader.add_preprocessor(classes_loader.load_classes)
