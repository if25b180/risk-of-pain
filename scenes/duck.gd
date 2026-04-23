extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var fly_speed: int

func _ready():
	animation_player.play("DuckFlying")

func _physics_process(delta: float) -> void:
	global_position.x -= fly_speed
	
	# TODO: remove magic numbers
	if (global_position.x < 0 || global_position.x > 315):
		fly_speed = -fly_speed
		$Sprite2D.flip_h = !$Sprite2D.flip_h
