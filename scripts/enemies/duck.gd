extends Enemy

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var fly_speed_range: Dictionary[String, float] = {
	min = 0.8,
	max = 1.9
}
@export var max_fly_distance: int = 200

@export var shit_chance_0_100: int = 2
@export var shit_scene: PackedScene

var min_x: float
var max_x: float
var start_global_position = null
var fly_speed = randf_range(fly_speed_range.min, fly_speed_range.max)

var timer = 0

#region SFX
@onready var shit_spawn_sfx: AudioStreamPlayer2D = $PoopSound
#endregion

func _ready():
	$Sprite2D.flip_h = true
	animation_player.play("DuckFlying")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if randi_range(0, 100) < shit_chance_0_100:
		Util.scene_instantiate(shit_scene, global_position)
		shit_spawn_sfx.play()
	
	if start_global_position == null:
		start_global_position = global_position
		min_x = global_position.x
		max_x = min_x + max_fly_distance
		return
	
	global_position.x += fly_speed
	
	timer += delta
	var bop_y = 16
	global_position.y = start_global_position.y + sin(timer * 2.0) * bop_y
	
	if (global_position.x < min_x || global_position.x > max_x):
		fly_speed = -fly_speed
		$Sprite2D.flip_h = !$Sprite2D.flip_h
