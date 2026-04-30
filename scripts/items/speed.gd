var speed_increase = 3.5

func on_pickup(player: Player):
	player.stats.speed += speed_increase
	print("Speed Item picked up: ", player.stats.speed)
