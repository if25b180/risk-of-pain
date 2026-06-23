extends Node2D
class_name Item

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var item_name: String = "TestItem"
@export var item_description: String = "ItemDescription"
@export var item_rarity: ItemPool.ItemRarity = ItemPool.ItemRarity.NORMAL

## Define a new item with a funtcion `on_pickup(player: Player)` inside a new .gd script
## and/or `on_player_attack_primary(own_item_count: int)` to hook into the player's primary attack
@export var item_script: GDScript

var item_image # TODO: Can be used later e. g. for displaying in UI
var item_script_instance
var timer = 0
var start_y = -1
var start_y_isset = false

#region Outline
var outline_width = 1
var outline_sprites: Array[Sprite2D] = []
var outline_offsets = [
	Vector2(-1, 0), Vector2(1, 0), # left, right
	Vector2(0, -1), Vector2(0, 1), # up, down
]
#endregion

func _ready():
	item_image = sprite_2d.texture
	sprite_2d.visible = false
	
	if not item_script:
		print(item_name, " does not have a Item Script .gd attached to it")
		return
		
	item_script_instance = item_script.new()
	
	#region Outline
	for outline_offset in outline_offsets:
		var sprite = Sprite2D.new()
		sprite.texture = item_image
		sprite.position = outline_offset * outline_width
		sprite.z_index = z_index - 1

		var mat = ShaderMaterial.new()
		mat.shader = PreloadManager.outline_shader
		mat.set_shader_parameter("flat_color", ItemPool.rarity_colors[item_rarity])
		sprite.material = mat

		add_child(sprite)
		outline_sprites.append(sprite)
		
	# Main sprite on top
	var main_sprite = Sprite2D.new()
	main_sprite.texture = item_image
	main_sprite.z_index = z_index  # in front of outline sprites
	add_child(main_sprite)
	#endregion
	
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
	player.stats.total_items_collected += 1

	#region Register/Call Item Behaviours
	var item_on_player_attack = null
	if item_script_instance.has_method("on_player_attack_primary"):
		item_on_player_attack = item_script_instance.on_player_attack_primary
		
	var item_on_passive = null
	if item_script_instance.has_method("on_passive"):
		item_on_passive = item_script_instance.on_passive
	
	if item_script_instance.has_method("on_pickup"):
		item_script_instance.on_pickup(player)
	#endregion
	
	#region Add Item to Player item list
	var item_scene = scene_file_path
	if not player.items.has(item_scene):
		player.items[item_scene] = {
			count = 1,
			attack_hook = item_on_player_attack,
			passive_hook = item_on_passive,
			item_image = item_image,
			item_name = item_name,
			item_description = item_description,
			item_rarity = item_rarity,
		}
	else:
		player.items[item_scene].count += 1
	
	player.item_inventory_ui()
	#endregion
	
	player.pickup_sfx.play()
	
	queue_free()
