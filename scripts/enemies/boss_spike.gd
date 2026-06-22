extends Node2D

var initial_position = Vector2.ZERO

var falling = false
var alive_time = 30
var alive_time_reset = 30
var damage = 20
var vspeed = 1.9
var vspeed_reset = 1.9

var warning_times = 7
var warning_times_reset = 7
var warning_blink_delay = 0.1

#region SFX
@onready var parry_sfx: AudioStreamPlayer2D = $ParrySound
#endregion

func prepare_fall():
	warning_times = warning_times_reset
	for i in range(warning_times * 2):
		$WarningSprite.visible = true
		await get_tree().create_timer(warning_blink_delay * 0.5).timeout
		$WarningSprite.visible = false
		await get_tree().create_timer(warning_blink_delay * 0.5).timeout
	
	$WarningSprite.visible = false
	$SpikeSprite.visible = true
	falling = true
	
func _ready() -> void:
	$WarningSprite.visible = false
	$SpikeSprite.visible = false
	initial_position = global_position
	
func _process(delta: float) -> void:
	if not falling:
		return
	
	alive_time -= delta
	if alive_time <= 0:
		queue_free()

func _physics_process(_delta: float) -> void:
	if not falling:
		return
	
	vspeed *= 1.05
	global_position.y += vspeed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not falling:
		return
	
	if body is Player:
		body.hurt(damage)
		
	if body is Player or body is TileMap or body is TileMapLayer:
		$SpikeSprite.visible = false
		falling = false
		vspeed = vspeed_reset
		alive_time = alive_time_reset
		global_position = initial_position
