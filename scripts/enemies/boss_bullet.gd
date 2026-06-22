extends Sprite2D

var alive_time = 10
var damage = 15
var speed = 2
var parried = false
var direction = 0
var saved_facing: Vector2 = Vector2.RIGHT

#region SFX
@onready var parry_sfx: AudioStreamPlayer2D = $ParrySound
#endregion

func on_parry():
	pass
	
	#if parried:
		#return
	#
	#if not Util.get_player():
		#return
	#
	#var label = PreloadManager.floating_text.instantiate()
	#get_tree().root.add_child(label)
	#label.global_position = global_position + Vector2(0, -30)
	#label.setup("PARRY", Color.YELLOW)
	#
	#saved_facing = Util.get_player().facing
	#parry_sfx.play()
	#parried = true

func _process(delta: float) -> void:
	alive_time -= delta
	if alive_time <= 0:
		queue_free()

func _physics_process(_delta: float) -> void:
	for area in $Area2D.get_overlapping_areas():
		var area_sprite: Node2D = area.get_parent()
		if not area_sprite.get_groups().has("player_attack") \
				or not area_sprite is Sprite2D:
			continue
			
		if area_sprite.visible:
			on_parry()
	
	var angle = deg_to_rad(direction)
	var direction_vec = Vector2(cos(angle), sin(angle))
	
	#if parried:
		#pass
		# Parrying is pretty OP for this bullet, so we disable it for now...
		# Don't know if balancing it is in the time budget anymore
		#cancel_free()
		#global_position.x += 2 * speed * saved_facing.x
	#else:
	global_position += direction_vec * speed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.hurt(damage)
		queue_free()
