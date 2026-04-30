extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var item_name: String = "TestItem"
## Define a new item with a funtcion `on_pickup(player: Player)` inside a new .gd script
@export var item_class: GDScript

var item_image # TODO: Can be used later e. g. for displaying in UI
var item_class_instance
var pickup_method_name = "on_pickup"
var timer = 0
var start_y = -1
var start_y_isset = false

func _ready():
	item_image = sprite_2d.texture
	item_class_instance = item_class.new()
	
func _physics_process(delta):
	if not start_y_isset:
		start_y = global_position.y
		start_y_isset = true
	
	timer += delta
	var bop_y = 2.0
	global_position.y = start_y + sin(timer * 2.0) * bop_y

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if not item_image or not item_class_instance:
		return
	
	if not body is Player:
		return
	
	if item_class_instance.has_method(pickup_method_name):
		item_class_instance.on_pickup(body)
	else:
		print("WARN: Item ", item_class, " has no method ", pickup_method_name)
	
	queue_free()
