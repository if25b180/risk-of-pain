extends Node
# See Project > Project Settings > Globals > Autoload

# public ->
var items: Array[PackedScene] = []

# We use `_` for signalizing private members since this is a global autoload
var _path_item_scenes = "res://scenes/items/pickups/"

# https://forum.godotengine.org/t/how-to-get-all-the-files-inside-a-folder/32086
func load_item_scenes():
	var dir = DirAccess.open(_path_item_scenes)
	dir.list_dir_begin()
	
	var default_item_name = "item.tscn" # Gets ignored

	while true:
		var file = dir.get_next()
		
		if file == "":
			break
		if file == default_item_name:
			continue
		
		if not file.begins_with("."):
			var scene = load(_path_item_scenes + file)
			items.append(scene)

	dir.list_dir_end()
