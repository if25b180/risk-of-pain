extends Sprite2D

var shit_damage = 15
var shit_speed = 2
var parried = false
var saved_facing: Vector2 = Vector2.RIGHT

#region SFX
@onready var parry_sfx: AudioStreamPlayer2D = $ParrySound
#endregion

const floating_text = preload("res://scenes/particles/floating_text.tscn")

func on_parry():
	if not Util.get_player():
		return
	
	var label = floating_text.instantiate()
	get_tree().root.add_child(label)
	label.global_position = global_position + Vector2(0, -30)
	label.setup("PARRY", Color.YELLOW)
	
	saved_facing = Util.get_player().facing
	print("PARRY")
	parry_sfx.play()
	parried = true
	

func _physics_process(_delta: float) -> void:
	for area in $Area2D.get_overlapping_areas():
		var area_sprite: Node2D = area.get_parent()
		if not area_sprite.get_groups().has("player_attack") \
				or not area_sprite is Sprite2D:
			continue
			
		if area_sprite.visible:
			on_parry()
	
	if parried:
		cancel_free()
		if Util.get_player():
			global_position.x += 2 * shit_speed * saved_facing.x
	else:
		global_position.y += shit_speed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is TileMap or body is TileMapLayer:
		queue_free()
		return
		
	if body is Player:
		body.hurt(shit_damage)
		queue_free()
