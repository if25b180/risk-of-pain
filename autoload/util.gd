extends Node

var _world_root: Node
func get_world_root() -> Node:
	if _world_root == null:
		_world_root = get_node_or_null("/root/Root")
	return _world_root

func get_player() -> Player:
	var potential_players = get_tree().get_nodes_in_group("player")
	for potential_player in potential_players:
		if potential_player is Player:
			return potential_player
			
	return null
	
func scene_instantiate(scene: PackedScene, global_position: Vector2, in_node: Node2D = null) -> Node2D:
	if in_node == null:
		in_node = Util.get_world_root()
	
	var new_node: Node2D = scene.instantiate()
	in_node.add_child(new_node)
	new_node.global_position = global_position
	
	return new_node

# See -> https://godotforums.org/d/35773-only-4-line-of-code-to-get-the-nearest-node/7
func find_closest_node(from_position: Vector2, group: String):
	var nodes = get_tree().get_nodes_in_group(group)
	nodes.sort_custom(
		func(a,b):
			return a.global_position.distance_to(from_position) < b.global_position.distance_to(from_position)
	)
	return nodes[0]
