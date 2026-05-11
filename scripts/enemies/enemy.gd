extends CharacterBody2D
class_name Enemy

@export var attack_area: Area2D

@export var health: float = 50
@export var damage: float = 15
@export var item_drop_chance_percent: int = 10

var player_in_focus = null
var max_health: float = health

func _ready():
	max_health = health
	attack_area.connect("body_entered", _on_attack_area_body_entered)
	attack_area.connect("body_exited", _on_attack_area_body_exited)


func hurt(received_damage):
	health -= received_damage
	if health <= 0:
		if randi_range(0, 100) < item_drop_chance_percent:
			print(ItemPool.items)
			var dropped_item_scene = ItemPool.items.pick_random()
			var dropped_item: Node2D = dropped_item_scene.instantiate()
			
			Util.get_world_root().add_child(dropped_item)
			dropped_item.global_position = global_position
		
		queue_free()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_focus = body

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_focus = null
