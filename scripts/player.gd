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
#endregion

@export var world_min_y: int = -500
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
}

# String = item_script_name | Dictionary = see `item.gd` -> `_on_pickup_area_body_entered()`
var items: Dictionary[String, Dictionary] = {}

var initial_stats = stats
var was_on_floor = false
var attack_secondary_locked = false

var chosen_slash = slash # left and right
var chosen_slash_area = slash_attack_area

var facing = Vector2.RIGHT

func reset_stats():
	stats = initial_stats

func hurt(damage, damager: Node = null):
	# is attacking, could benefit from its own variable readability wise...
	if chosen_slash and chosen_slash.visible:
		velocity.x -= facing.x * stats.parry_force
		
		if damager and damager.has_method('on_parry'):
			damager.on_parry()
		
		return
	
	hurt_sfx.play()
	stats.health -= damage
	if stats.health <= 0:
		get_tree().reload_current_scene()

func _physics_process(_delta):
	#region Movement
	if global_position.y <= world_min_y:
		global_position.y += 50
	
	velocity.x *= stats.slipperiness
	
	if not is_on_floor():
		velocity.y += stats.gravity
	
	var direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.x += direction * stats.speed
	
	if direction != 0:
		facing.x = direction
	
	if Input.is_action_just_pressed("jump"):
		var has_jumped = is_on_floor() || is_on_wall()
		if is_on_floor(): # Normal jump
			velocity.y = stats.jump_force
		elif is_on_wall(): # Walljump
			velocity.x = stats.wall_jump_force * direction
			velocity.y = stats.jump_force
		
		# SFX and Animation should happen on either wall jump or normal jump
		if has_jumped:
			animation.play("p_jump")
			jump_sfx.play()
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= stats.jump_release_multiplier
	#endregion
	
	#region Animations
	if direction != 0:
		sprite.flip_h = direction < 0
		slash.flip_h = direction < 0
		
		
	if not is_on_floor():
		if animation.current_animation != "p_air":
			animation.play("p_air")
	else:
		if direction != 0:
			if animation.current_animation != "p_run":
				animation.play("p_run")
				if is_on_floor():
					walk_sfx.play()
		else:
			if animation.current_animation != "p_idle":
				animation.play("p_idle")
	#endregion
	
	#region Attacking
	if direction != 0:
		slash_attack_area_collider.position.x = abs(slash_attack_area_collider.position.x) * direction
	
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
		
		var list_item = item_list.add_item(item_counter, item_data.item_image)
		item_list.set_item_tooltip(list_item, item_data.item_description)
		item_list.set_item_selectable(list_item, false)
	

func attack():
	if slash.visible \
			or slash_down.visible \
			or slash_up.visible:
		return
	
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
	
	var new_node: Node2D = attack_secondary_scene.instantiate()
	Util.get_world_root().add_child(new_node)
	new_node.global_position = global_position
	new_node.direction = facing
	_attack_secondary_timeout()
	
func _attack_secondary_timeout():
	attack_secondary_locked = true
	await get_tree().create_timer(attack_duration).timeout
	attack_secondary_locked = false
