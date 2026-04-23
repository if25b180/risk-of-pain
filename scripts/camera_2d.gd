extends Camera2D

@export var min_x: int = 0
@export var mouse_panning_factor: int = 30
@export var smooth_speed: float = 0.35

@export var player: CharacterBody2D

func _physics_process(_delta: float) -> void:
	# Make camera follow player
	global_position = \
		lerp(global_position, player.global_position, smooth_speed) \
		- (player.global_position - get_global_mouse_position()) / mouse_panning_factor
	
	if global_position.x < min_x:
		global_position.x = min_x
