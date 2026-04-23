extends Node2D

@export var player: CharacterBody2D
@export var label_scaler: Node2D
@export var boss_scene: PackedScene
@export var world_root: Node2D

var boss_already_spawned = false

func _physics_process(_delta: float) -> void:
	label_scaler.visible = (player.global_position.distance_to(global_position) < 100)
	
func _process(_delta: float) -> void:
	if boss_already_spawned:
		return
	
	if Input.is_action_just_pressed("interact"):
		var boss: Node2D = boss_scene.instantiate()
		world_root.add_child(boss)
		boss.global_position = Vector2(global_position.x, global_position.y - 64)
	
		boss_already_spawned = true
