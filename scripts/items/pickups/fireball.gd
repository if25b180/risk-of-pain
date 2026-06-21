extends Node

var fireball_chance = 10

func on_player_attack_primary(player: Player, own_item_count: int):
	if randi_range(0, 100) < fireball_chance * own_item_count:
		var fireball_projectile = \
			Util.scene_instantiate(PreloadManager.fireball_projectile, player.global_position)
		fireball_projectile.default_direction = player.facing
		player.fireball_sfx.play()
