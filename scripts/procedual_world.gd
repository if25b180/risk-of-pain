extends TileMapLayer

@export var floor_min_y: int = 0 # This is TileMap position NOT World position!
@export var y_jump_range_min: int = -6
@export var y_jump_range_max: int = 6
@export var chunk_width: int = 10

@export var player: CharacterBody2D

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
	for i in range(chunk_width):
		var current_x = chunk_count * chunk_width + i
		
		# First Chunk also creates barrier
		if chunk_count == 0:
			for j in range(-500, 500):
				set_cell(Vector2i(current_x - chunk_width, floor_current_y + j), tilesets.grass, tiles.dirt_middle)
		
		set_cell(Vector2i(current_x, floor_current_y), tilesets.grass, tiles.grass_middle)
		
		var dirt_depth = 100
		for j in range(1, dirt_depth):
			set_cell(Vector2i(current_x, floor_current_y + j), tilesets.grass, tiles.dirt_middle)
	
	chunk_count += 1

func _ready() -> void:
	floor_current_y = floor_min_y
	
	# Pregenerate a bunch
	for i in range(100):
		generate_next()
	pass

func _process(delta: float) -> void:
	var camera_box_right = get_viewport().get_camera_2d().global_position.x + get_viewport_rect().size.x
	#print(camera_box_right)
	
	if (camera_box_right / tile_set.tile_size.x) > (chunk_width * chunk_count):
		generate_next()
	
	
	
	
	
