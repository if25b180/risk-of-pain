extends Node2D

@export var fly_speed: float = 100
@export var fly_speed_multiplier: float = 1.05
@export var damage: float = 10

var range = 500000 # XD
var target_enemy: Enemy = null
var target_position = Vector2.ZERO
var default_direction = Vector2.UP

func _ready() -> void:
	var input = Vector2.ZERO
	if Input.is_action_pressed("move_left"): input.x -= 1
	if Input.is_action_pressed("move_right"): input.x += 1
	if Input.is_action_pressed("move_down"): input.y += 1
	if Input.is_action_pressed("move_up"): input.y -= 1
	
	#default
	if input == Vector2.ZERO:
		input = default_direction
	
	target_position = global_position + input.normalized() * range

func _physics_process(delta: float) -> void:
	fly_speed *= fly_speed_multiplier
	
		
	global_position = global_position.move_toward(target_position, fly_speed * delta)
	if (global_position == target_position):
		queue_free()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is TileMap or body is TileMapLayer:
		queue_free()
		return
	


func _on_attack_area_area_entered(area: Area2D) -> void:
	if not area is EnemyHitbox:
		return
		
	var hit_enemy = area.get_parent()
	if not hit_enemy is Enemy:
		print("EnemyHitbox attached to non-Enemy type? (", hit_enemy, ")")
		return
	
	if hit_enemy.has_method("hurt"):
		hit_enemy.hurt(damage)
	else:
		print(hit_enemy, " is missing function `hurt()`!")
