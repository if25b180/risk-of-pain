extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var fly_speed: int
@export var max_fly_distance: int = 200

@export var health: float = 10
@export var damage: float = 20

var min_x = global_position.x
var max_x = min_x + max_fly_distance

func _ready():
	animation_player.play("DuckFlying")

func _physics_process(_delta: float) -> void:
	global_position.x += fly_speed
	
	if (global_position.x < min_x || global_position.x > max_x):
		fly_speed = -fly_speed
		$Sprite2D.flip_h = !$Sprite2D.flip_h
