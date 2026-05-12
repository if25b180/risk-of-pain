extends Node

var gravity_multiplier = 0.7

func on_passive(player: Player, count: int):
	player.stats.gravity = player.initial_stats.gravity * pow(gravity_multiplier, count)
	print("gravity: ", player.stats.gravity)
