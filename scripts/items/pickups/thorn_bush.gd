extends Node2D

var thorns_damage = 10

func on_pickup(player: Player):
		player.stats.thorns_damage += 10
