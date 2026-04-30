var damage_increase = 3.5

func on_pickup(player: Player):
	player.stats.damage_primary += damage_increase
	print("Damage Primary Increase picked up: ", player.stats.damage_primary)
