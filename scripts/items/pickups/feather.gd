extends Node

var jump_count = 0

func on_passive(player: Player, item_count):
	if player.is_on_floor() or player.is_on_wall():
		jump_count = item_count + 1
		
	if Input.is_action_just_pressed("jump") and jump_count > 0:
		player.velocity.y = player.stats.jump_force
		player.jump_count += 1
		player.jump_sfx.pitch_scale = 0.8 + (player.jump_count - 1) * 0.1
		player.jump_sfx.play()
		jump_count -= 1
