extends TileMapLayer

@export var floor_min_y: int = 0 # This is TileMap position NOT World position!
@export var y_jump_range_min: int = -6
@export var y_jump_range_max: int = 6
@export var chunk_width: int = 10
@export var tree_chance: int = 30
@export var boss_spawner_chunk: int = 3

@export var player: CharacterBody2D
@export var world_root: Node2D
@export var boss_spawner: Node2D

@export var tree_scene: PackedScene

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

func generate_next():
	floor_current_y += randi_range(y_jump_range_min, y_jump_range_max)
	floor_current_y = clamp(floor_current_y, floor_min_y, 1400)
	
	if randi_range(0, 100) > 100 - tree_chance:
		var tree: Node2D = tree_scene.instantiate()
		var tree_x = chunk_count * chunk_width * tile_set.tile_size.x \
			+ randi_range(3, chunk_width - 3) * tile_set.tile_size.x
		var tree_y = floor_current_y * tile_set.tile_size.y
		world_root.add_child(tree)
		tree.global_position = Vector2(tree_x, tree_y)
		tree.z_index = -1
	
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

func _ready() -> void:
	floor_current_y = floor_min_y

func _process(delta: float) -> void:
	var camera_box_right = get_viewport().get_camera_2d().global_position.x + get_viewport_rect().size.x
	#print(camera_box_right)
	
	# Fill camera void
	if (camera_box_right / tile_set.tile_size.x) > (chunk_width * chunk_count):
		generate_next()
	
	
	
	
	
