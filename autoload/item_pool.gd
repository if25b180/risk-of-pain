extends Node
# See Project > Project Settings > Globals > Autoload

enum ItemRarity {
	NORMAL,
	RARE,
	LEGENDARY
}

# public ->
var items: Array[PackedScene] = []
var rarity_colors = [
	Color.WHITE, # NORMAL
	Color.GREEN_YELLOW, # RARE
	Color.MEDIUM_VIOLET_RED # LEGENDARY
]

func get_random_item():
	print("item random get")
	var chance = randi_range(0, 100)
	var chosen_rarity = ItemRarity.NORMAL
	
	if chance < 35:
		chosen_rarity = ItemRarity.RARE
	if chance < 5:
		chosen_rarity = ItemRarity.LEGENDARY
	
	# TODO: Maybe make this a more efficient algorithm
	var chosen_item: PackedScene = items.pick_random()
	var chosen_item_instance: Item = chosen_item.instantiate()
	var retries = 100
	while chosen_item_instance.item_rarity != chosen_rarity:
		if retries <= 0:
			break
		
		chosen_item = items.pick_random()
		
		chosen_item_instance.free() # Immediate free as to not execute its code
		chosen_item_instance = chosen_item.instantiate()
		
		retries -= 1
	
	return chosen_item

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
			if scene:
				items.append(scene)

	dir.list_dir_end()
