extends Node2D

@onready var label: Label = $Label
@onready var good_sfx: AudioStreamPlayer2D = $ItemUpgrade
@onready var neutral_sfx: AudioStreamPlayer2D = $ItemSame
@onready var bad_sfx: AudioStreamPlayer2D = $ItemLost

var player: CharacterBody2D

var is_spinning = false

func _ready():
	player = Util.get_player()
	label.position = Vector2(-13, -20)

func _physics_process(_delta: float) -> void:
	label.visible = player.global_position.distance_to(global_position) < 64

func _process(_delta: float) -> void:
	if is_spinning:
		return
	
	if player.global_position.distance_to(global_position) < 64 \
			and Input.is_action_just_pressed("interact"):
		_spin(player as Player)

func _spin(player: Player) -> void:
	var common_items: Array = []
	for item_scene in player.items:
		if player.items[item_scene].item_rarity == ItemPool.ItemRarity.NORMAL:
			common_items.append(item_scene)
	
	if common_items.is_empty():
		print("Slotmachine: Keine NORMAL items im Inventar!")
		return
	
	is_spinning = true
	
	var chosen_scene_path: String = common_items.pick_random()
	var chosen_item_data: Dictionary = player.items[chosen_scene_path]
	
	if chosen_item_data.count > 1:
		player.items[chosen_scene_path].count -= 1
	else:
		player.items.erase(chosen_scene_path)
	
	player.item_inventory_ui()
	player.recalculate_stats()
	
	var roll = randi_range(0, 2)
	match roll:
		0:
			_spawn_text("Item lost!", Color.RED)
			bad_sfx.play()
		1:
			_give_item_of_rarity(ItemPool.ItemRarity.NORMAL)
			_spawn_text("Equivalent Item drop!", Color.WHITE)
			neutral_sfx.play()
		2:
			var new_rarity = chosen_item_data.item_rarity + 1
			if new_rarity > ItemPool.ItemRarity.LEGENDARY:
				new_rarity = ItemPool.ItemRarity.LEGENDARY
			_give_item_of_rarity(new_rarity)
			_spawn_text("Item Upgrade!", Color.YELLOW)
			good_sfx.play()
	
	await get_tree().create_timer(1.0).timeout
	is_spinning = false

func _give_item_of_rarity(rarity: ItemPool.ItemRarity) -> void:
	var candidates: Array[PackedScene] = []
	for scene in ItemPool.items:
		var instance: Item = scene.instantiate()
		if instance.item_rarity == rarity:
			candidates.append(scene)
		instance.free()
	
	if candidates.is_empty():
		return
	
	var new_item: Node2D = candidates.pick_random().instantiate()
	Util.get_world_root().add_child(new_item)
	new_item.global_position = global_position + Vector2(0, -30)



func _spawn_text(msg: String, color: Color) -> void:
	var ft = PreloadManager.floating_text.instantiate()
	Util.get_world_root().add_child(ft)
	ft.global_position = global_position + Vector2(0, -40)
	ft.setup(msg, color)
