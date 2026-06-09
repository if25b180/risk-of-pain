extends Node2D

@export var extend_speed: float = 8.0
@export var retract_speed: float = 12.0
@export var middle_point: Node2D
@export var max_rotation_offset: float = 8.0
@export var base_delay: float = 0.2
@export var max_delay: float = 1.2
@export var max_distance: float = 300.0
@export var damage: int = 10

var is_dangerous: bool = false
var target_scale_y: float = 0.0
var delay_timer: float = 0.0
var extending: bool = false

func _process(delta: float):
	if delay_timer > 0.0:
		delay_timer -= delta
		return

	var target = target_scale_y
	var speed = extend_speed if target > scale.y else retract_speed
	scale.y = move_toward(scale.y, target, speed * delta)

	if extending and scale.y >= 1.0:
		is_dangerous = true
	if not extending and scale.y <= 0.0:
		rotation_degrees = 0.0

func extend():
	extending = true
	target_scale_y = 1.0

	rotation_degrees = randf_range(-max_rotation_offset, max_rotation_offset)

	if middle_point:
		var distance = global_position.distance_to(middle_point.global_position)
		var lerp_speed = clamp(distance / max_distance, 0.0, 1.0)
		delay_timer = lerp(max_delay, base_delay, lerp_speed)

func disengage():
	extending = false
	is_dangerous = false
	target_scale_y = 0.0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_dangerous:
		return
	
	if body is Player:
		body.hurt(damage)
		disengage()
