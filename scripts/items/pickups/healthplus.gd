var health_increase = 10

func on_pickup(player: Player):
	print("Health Increase From: ", player.stats.max_health)
	player.stats.health += health_increase
	player.stats.max_health += health_increase
	print("Health Increase To: ", player.stats.max_health)
