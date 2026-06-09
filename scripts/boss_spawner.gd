extends Node2D

@export var player: CharacterBody2D
@export var boss_arena_spawnpoint: Node2D
@export var camera_2d: Camera2D
@export var boss_scene: PackedScene

var boss_already_spawned = false

func _physics_process(_delta: float) -> void:
	if player.global_position.distance_to(global_position) < 64:
		$LabelScaler.visible = true
		$Sprite2D.modulate.a = lerp($Sprite2D.modulate.a, 1.0, 0.2)
	else:
		$LabelScaler.visible = false
		$Sprite2D.modulate.a = lerp($Sprite2D.modulate.a, 0.0, 0.2)
	
func _process(_delta: float) -> void:
	if boss_already_spawned:
		return
	
	if player.global_position.distance_to(global_position) < 64 \
			and Input.is_action_just_pressed("interact"):
		Util.get_player().global_position = boss_arena_spawnpoint.global_position
		camera_2d.is_bound_to_world = false
	
		boss_already_spawned = true
