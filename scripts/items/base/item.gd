extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var item_name: String = "TestItem"
@export var item_description: String = "ItemDescription"

## Define a new item with a funtcion `on_pickup(player: Player)` inside a new .gd script
## and/or `on_player_attack_primary(own_item_count: int)` to hook into the player's primary attack
@export var item_script: GDScript

var item_image # TODO: Can be used later e. g. for displaying in UI
var item_script_instance
var timer = 0
var start_y = -1
var start_y_isset = false

func _ready():
	item_image = sprite_2d.texture
	
	if not item_script:
		print(item_name, " does not have a Item Script .gd attached to it")
		return
		
	item_script_instance = item_script.new()
	
func _physics_process(delta):
	if not start_y_isset:
		start_y = global_position.y
		start_y_isset = true
	
	timer += delta
	var bop_y = 2.0
	global_position.y = start_y + sin(timer * 2.0) * bop_y

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if not item_image or not item_script_instance:
		return
	
	if not body is Player:
		return
	
	var player = body as Player

	#region Register/Call Item Behaviours
	var item_on_player_attack = null
	if item_script_instance.has_method("on_player_attack_primary"):
		item_on_player_attack = item_script_instance.on_player_attack_primary
	
	if item_script_instance.has_method("on_pickup"):
		item_script_instance.on_pickup(player)
	#endregion
	
	#region Add Item to Player item list
	var item_scene = scene_file_path
	if not player.items.has(item_scene):
		player.items[item_scene] = {
			count = 1,
			attack_hook = item_on_player_attack,
			item_image = item_image,
			item_name = item_name,
			item_description = item_description
		}
	else:
		player.items[item_scene].count += 1
	
	player.item_inventory_ui()
	#endregion
	
	queue_free()
