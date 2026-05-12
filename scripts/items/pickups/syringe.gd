extends Node

var health_regen = 0.045

func on_passive(player: Player, item_count: int):
	player.stats.health += health_regen * item_count;
	player.stats.health = min(player.stats.health, player.stats.max_health)
