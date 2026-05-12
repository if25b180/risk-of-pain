extends Node

var dash_force = 900
var dash_timeout = 1
var dash_on_cooldown = false
var horizontal = 1
var allow_dash = false

func on_passive(player: Player, _item_count):
	if player.is_on_floor():
		allow_dash = true
	
	if Input.is_action_pressed("move_right"):
		horizontal = 1
	if Input.is_action_pressed("move_left"):
		horizontal = -1
		
	if allow_dash and not dash_on_cooldown and Input.is_action_just_pressed("dash"):
		print("DASH!")
		player.velocity.x = dash_force * horizontal
		allow_dash = false
		_dash_cooldown()
		
func _dash_cooldown():
	dash_on_cooldown = true
	await Util.get_world_root().get_tree().create_timer(dash_timeout).timeout
	dash_on_cooldown = false
