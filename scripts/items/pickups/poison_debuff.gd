extends Node

func on_player_attack_primary(player: Player, own_item_count: int):
	var areas = player.chosen_slash_area.get_overlapping_areas()
	for area in areas:
		if not area is EnemyHitbox:
			continue
		var enemy = area.get_parent()
		if enemy.has_method("apply_poison"):
			enemy.apply_poison(1.0 * own_item_count)
