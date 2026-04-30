extends Node

var fireball_chance = 10

func on_player_attack_primary(player: Player, own_item_count: int):
	if randi_range(0, 100) < fireball_chance * own_item_count:
		var fireball_projectile: Node2D = PreloadManager.fireball_projectile.instantiate()
		Util.get_world_root().add_child(fireball_projectile)
		
		fireball_projectile.global_position = player.global_position
		fireball_projectile.target_enemy = Util.find_closest_node(player.global_position, "enemy")
