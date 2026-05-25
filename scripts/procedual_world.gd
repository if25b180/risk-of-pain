extends TileMapLayer

@export var floor_min_y: int = 0 ## This is TileMap position NOT World position!
@export var floor_max_y: int = 1400 ## This is TileMap position NOT World position!
@export var y_jump_range_min: int = -6
@export var y_jump_range_max: int = 6
@export var chunk_width: int = 10
@export var boss_spawner_chunk: int = 3

@export var boss_spawner: Node2D
@export var player: CharacterBody2D

#region Random Node Spawns
@export var tree_chance: int = 30
@export var enemy_chance: int = 10
@export var duck_chance: int = 10
@export var pillar_chance: int = 10
@export var boulder_chance: int = 15
#endregion

var chunk_count = 0
var floor_current_y = -1

var tilesets = {
	dirt = 0,
	grass = 2,
}

var tiles = {
	grass_middle = Vector2i(2, 0),
	dirt_middle = Vector2i(5, 0),
}

func node_chance(
	scene: PackedScene,
	chance_0_100: int,
	terrain_padding: int,
	position_offset: Vector2 = Vector2.ZERO
):
	if (clamp(chance_0_100, 0, 100) != chance_0_100):
		print("Node Spawn Chance for ", scene, " is not between 0 and 100")
		return null
	
	if randi_range(0, 100) < chance_0_100:
		var new_node: Node2D = scene.instantiate()
		var x = chunk_count * chunk_width * tile_set.tile_size.x \
			+ randi_range(terrain_padding, chunk_width - terrain_padding) \
			* tile_set.tile_size.x
		var y = floor_current_y * tile_set.tile_size.y
		
		Util.get_world_root().add_child(new_node)
		new_node.global_position = Vector2(x + position_offset.x, y + position_offset.y)
	
		return new_node
	
	return null

func generate_next_chunk():
	floor_current_y += randi_range(y_jump_range_min, y_jump_range_max)
	floor_current_y = clamp(floor_current_y, floor_min_y, floor_max_y)
	
	# Spawning stuff in first 2 chunks is risky... player might get stuck
	if chunk_count > 1:
		node_chance(PreloadManager.tree_structure, tree_chance, 3)
		node_chance(PreloadManager.knight_enemy, enemy_chance, 2, Vector2(0, -50))
		node_chance(PreloadManager.duck_enemy, duck_chance, 2, Vector2(0, -100))
		for i in range(2):
			node_chance(PreloadManager.pillar_structure, pillar_chance * 0.5, 3, Vector2(0, randi_range(0, 80)))
		node_chance(PreloadManager.boulder_structure, boulder_chance, 3)
	
	for i in range(chunk_width):
		var current_x = chunk_count * chunk_width + i
		
		# First Chunk creates barrier
		if chunk_count == 0:
			for j in range(-500, 500):
				set_cell(
					Vector2i(current_x - chunk_width, floor_current_y + j),
					tilesets.grass, tiles.dirt_middle
				)
		
		if chunk_count == boss_spawner_chunk:
			boss_spawner.global_position = \
				Vector2i(current_x * tile_set.tile_size.x, floor_current_y * tile_set.tile_size.y)
		
		set_cell(
			Vector2i(current_x, floor_current_y),
			tilesets.grass, tiles.grass_middle
		)
		
		var dirt_depth = 100
		for j in range(1, dirt_depth):
			set_cell(
				Vector2i(current_x, floor_current_y + j),
				tilesets.grass, tiles.dirt_middle
			)
	
	chunk_count += 1

func _ready():
	floor_current_y = floor_min_y

func _process(_delta):
	var camera_box_right = get_viewport().get_camera_2d().global_position.x + get_viewport_rect().size.x
	#print(camera_box_right)
	
	# Fill camera void
	if (camera_box_right / tile_set.tile_size.x) > (chunk_width * chunk_count):
		generate_next_chunk()
	
	
	
	
	
