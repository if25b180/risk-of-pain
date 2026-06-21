extends CharacterBody2D
class_name Player

@onready var sprite: Sprite2D = $PlayerNormal
@onready var animation: AnimationPlayer = $AnimationPlayer

#region Slashing up/down/left/right
@onready var slash: Sprite2D = $PlayerSlash
@onready var slash_attack_area: Area2D = $PlayerSlash/AttackArea
@onready var slash_attack_area_collider: CollisionShape2D = $PlayerSlash/AttackArea/CollisionShape2D

@onready var slash_up: Sprite2D = $PlayerSlashUp
@onready var slash_up_attack_area: Area2D = $PlayerSlashUp/AttackArea
@onready var slash_up_attack_area_collider: CollisionShape2D = $PlayerSlashUp/AttackArea/CollisionShape2D

@onready var slash_down: Sprite2D = $PlayerSlashDown
@onready var slash_down_attack_area: Area2D = $PlayerSlashDown/AttackArea
@onready var slash_down_attack_area_collider: CollisionShape2D = $PlayerSlashDown/AttackArea/CollisionShape2D
#endregion

#region UI Elements
@onready var healthbar: ProgressBar = $Healthbar
@onready var item_list: ItemList = $"../Camera2D/ItemList"
#endregion

#region SFX
@onready var jump_sfx: AudioStreamPlayer2D = $JumpSound
@onready var walk_sfx: AudioStreamPlayer2D = $WalkSound
@onready var hurt_sfx: AudioStreamPlayer2D = $HurtSound
@onready var swing_sfx: AudioStreamPlayer2D = $SwingSound
@onready var bow_sfx: AudioStreamPlayer2D = $BowSound
@onready var pickup_sfx: AudioStreamPlayer2D = $PickupSound
@onready var fireball_sfx: AudioStreamPlayer2D = $FireBallSound
@onready var dash_sfx: AudioStreamPlayer2D = $DashSound
#endregion

@export var world_min_y: int = -1500
@export var attack_duration: float = 0.4

@export var attack_secondary_scene: PackedScene

@export var stats: Dictionary[String, float] = {
	health = 100,
	max_health = 100,
	damage_primary = 20,
	damage_secondary = 30,
	speed = 50,
	slipperiness = 0.65,
	gravity = 20,
	jump_force = -300,
	jump_release_multiplier = 0.45,
	wall_jump_force = -300,
	pogo_force = -300,
	parry_force = 300,
	thorns_damage = 0
}

# String = item_script_name | Dictionary = see `item.gd` -> `_on_pickup_area_body_entered()`
var items: Dictionary[String, Dictionary] = {}

var initial_stats = stats.duplicate()
var was_on_floor = false
var attack_secondary_locked = false

var chosen_slash = slash # left and right
var chosen_slash_area = slash_attack_area

var facing = Vector2.RIGHT
var jump_count = 0

func reset_stats():
	stats = initial_stats

func hurt(damage, damager: Node = null):
	# is attacking, could benefit from its own variable readability wise...
	if chosen_slash and chosen_slash.visible:
		velocity.x -= facing.x * stats.parry_force
		
		if damager and damager.has_method('on_parry'):
			damager.on_parry()
		
		return
	
	if damager and damager.has_method("hurt") and stats.thorns_damage > 0:
		damager.hurt(stats.thorns_damage)
	
	hurt_sfx.play()
	stats.health -= damage
	
	var label = PreloadManager.floating_text.instantiate()
	get_tree().root.add_child(label)
	label.global_position = global_position + Vector2(-20, -30)
	label.setup(int(damage), Color.REBECCA_PURPLE)
	
	if stats.health <= 0:
		get_tree().reload_current_scene()

func _physics_process(_delta):
	#region Movement
	if global_position.y <= world_min_y:
		global_position.y += 50
	
	velocity.x *= stats.slipperiness
	
	if not is_on_floor():
		velocity.y += stats.gravity
	
	var direction_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var direction_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	velocity.x += direction_x * stats.speed
	
	if direction_x != 0:
		facing = Vector2(direction_x, direction_y)
	
	if is_on_floor():
		jump_count = 0
	
	if Input.is_action_just_pressed("jump"):
		var has_jumped = is_on_floor() || is_on_wall()
		if is_on_floor(): # Normal jump
			velocity.y = stats.jump_force
		elif is_on_wall(): # Walljump
			velocity.x = stats.wall_jump_force * direction_x
			velocity.y = stats.jump_force
		
		# SFX and Animation should happen on either wall jump or normal jump
		if has_jumped:
			animation.play("p_jump")
			jump_sfx.pitch_scale = 0.8 + (jump_count - 1) * 0.1
			jump_count += 1
			jump_sfx.play()
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= stats.jump_release_multiplier
	#endregion
	
	#region Animations
	if direction_x != 0:
		sprite.flip_h = direction_x < 0
		slash.flip_h = direction_x < 0
		
		
	if not is_on_floor():
		if animation.current_animation != "p_air":
			animation.play("p_air")
	else:
		if direction_x != 0:
			if animation.current_animation != "p_run":
				animation.play("p_run")
				if is_on_floor():
					walk_sfx.play()
		else:
			if animation.current_animation != "p_idle":
				animation.play("p_idle")
	#endregion
	
	#region Attacking
	if direction_x != 0:
		slash_attack_area_collider.position.x = abs(slash_attack_area_collider.position.x) * direction_x
	
	if Input.is_action_just_pressed("attack_primary"):
		attack()
	
	if Input.is_action_just_pressed("attack_secondary"):
		attack_secondary()
	#endregion
	
	#region Passive Item Effects
	for item_scene in items:
		var item_properties = items[item_scene]
		
		if item_properties.passive_hook != null:
			item_properties.passive_hook.call($".", item_properties.count)
	#endregion
	
	# Healtbar
	healthbar.value = (stats.health / stats.max_health) * 100
	
	# We wanna move and slide at the end just in case any item manipulates movement
	# (e. g. See `dash.gd`)
	move_and_slide()
	
func item_inventory_ui() -> void:
	item_list.clear()

	for item_scene in items:
		var item_data = items[item_scene]
		var item_counter = "x%d" % item_data.count

		var outlined_icon = make_outlined_icon(item_data.item_image, item_data.item_rarity)
		var list_item = item_list.add_item(item_counter, outlined_icon)
		item_list.set_item_tooltip(list_item, item_data.item_description)
		item_list.set_item_selectable(list_item, false)
		
	var item_count = item_list.item_count
	if item_count > 10:
		item_list.custom_minimum_size.y = 30
		
func attack():
	if slash.visible \
			or slash_down.visible \
			or slash_up.visible:
		return
	
	swing_sfx.play()
	
	chosen_slash = slash # left and right
	chosen_slash_area = slash_attack_area
	if Input.is_action_pressed("move_down") and not is_on_floor():
		chosen_slash = slash_down
		chosen_slash_area = slash_down_attack_area
	if Input.is_action_pressed("move_up"):
		chosen_slash = slash_up
		chosen_slash_area = slash_up_attack_area
	
	sprite.visible = false
	chosen_slash.visible = true
	
	for item_scene in items:
		var item_properties = items[item_scene]
		
		if item_properties.attack_hook != null:
			item_properties.attack_hook.call($".", item_properties.count)
	
	var areas = chosen_slash_area.get_overlapping_areas()
	for area in areas:
		if not area is EnemyHitbox:
			continue
		var hit_enemy = area.get_parent()
		if not hit_enemy is Enemy:
			print("EnemyHitbox attached to non-Enemy type? (", hit_enemy, ")")
			continue
		
		if chosen_slash == slash_down:
			velocity.y = stats.pogo_force
		
		if hit_enemy.has_method("hurt"):
			hit_enemy.hurt(stats.damage_primary)
		else:
			print(hit_enemy, " is missing function `hurt()`!")
	
	await get_tree().create_timer(attack_duration).timeout
	sprite.visible = true
	chosen_slash.visible = false
	
func attack_secondary():
	if attack_secondary_locked:
		return
	
	if not attack_secondary_scene:
		print("WARN: Player has no secondary attack attached!")
		return
	
	var new_node = Util.scene_instantiate(attack_secondary_scene, global_position)
	bow_sfx.play()
	
	new_node.direction.x = facing.x
	if Input.is_action_pressed("move_down") and not is_on_floor():
		new_node.direction.x = 0
		new_node.direction.y = 1
	if Input.is_action_pressed("move_up"):
		new_node.direction.x = 0
		new_node.direction.y = -1
		
	_attack_secondary_timeout()
	
func _attack_secondary_timeout():
	attack_secondary_locked = true
	await get_tree().create_timer(attack_duration).timeout
	attack_secondary_locked = false

func make_outlined_icon(source: Texture2D, rarity: int) -> ImageTexture:
	var color = ItemPool.rarity_colors[rarity]
	var src_img = source.get_image()
	
	# We are drawing the outline on CPU because Godot does NOT support shaders
	# on individual ItemList entries... -> we need to guarantee a format known by the CPU,
	# which RGBA8 is
	src_img.convert(Image.FORMAT_RGBA8)

	# We need to extend the sprite bounds because otherwise the outline gets cut off
	var padding = 2
	var new_size = Vector2i(src_img.get_width() + padding * 2, src_img.get_height() + padding * 2)
	var dst_img = Image.create(new_size.x, new_size.y, false, Image.FORMAT_RGBA8)

	# Draw outline pixels
	var offsets = [
		Vector2i(-1, 0), Vector2i(1, 0),
		Vector2i(0, -1), Vector2i(0, 1),
	]
	for x in src_img.get_width():
		for y in src_img.get_height():
			var a = src_img.get_pixel(x, y).a
			if a < 0.01: # Skip (almost) invisible pixels
				continue
			
			for offset in offsets:
				var offsetx = x + padding + offset.x
				var offsety = y + padding + offset.y
				if dst_img.get_pixel(offsetx, offsety).a < 0.01:
					dst_img.set_pixel(offsetx, offsety, color)

	# Draw original sprite on top
	for x in src_img.get_width():
		for y in src_img.get_height():
			var px = src_img.get_pixel(x, y)
			if px.a > 0.01:
				dst_img.set_pixel(x + padding, y + padding, px)

	return ImageTexture.create_from_image(dst_img)
