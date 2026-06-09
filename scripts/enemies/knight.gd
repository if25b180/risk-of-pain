extends Enemy
class_name Knight

@export var speed: float = 50.0
@export var gravity: float = 900.0
@export var attack_duration: float = 0.5

@export var normal_texture: Texture2D
@export var attack_texture: Texture2D

@onready var floor_ray = $FloorDetector
@onready var player_ray = $PlayerDetector
@onready var sprite = $Sprite2D

var direction = 1 
var is_attacking = false
var already_attacked = false

func hurt(damage):
	super.hurt(damage)
	
	var label = PreloadManager.floating_text.instantiate() 
	get_tree().root.add_child(label)
	label.global_position = global_position + Vector2(0, -30)
	label.setup(int(damage))
	
	var player = Util.get_player()
	if player:
		var player_dir = sign(player.global_position.x - global_position.x)
		if player_dir != 0 and player_dir != direction:
			flip_direction()

func _physics_process(delta):
	super._physics_process(delta)
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_attacking:
		velocity.x = 0
		move_and_slide()
		
		if player_in_focus and not already_attacked:
			player_in_focus.hurt(damage, self)
			already_attacked = true
		
		return

	check_for_player()

	if not floor_ray.is_colliding() or is_on_wall():
		flip_direction()

	velocity.x = direction * speed
	move_and_slide()

func check_for_player():
	if player_ray.is_colliding():
		var collider = player_ray.get_collider()
		if collider and collider is Player:
			start_attack()

func start_attack():
	is_attacking = true
	already_attacked = false
	
	if attack_texture:
		sprite.texture = attack_texture
	
	await get_tree().create_timer(attack_duration).timeout
	
	if normal_texture:
		sprite.texture = normal_texture
	
	# If it weren't for this could sometimes lead to a softlock
	# if we killed the enemy and then the await ends
	if not is_instance_valid(self):
		print("WARN: Softlock Crisis averted")
		return
	
	is_attacking = false

func flip_direction():
	direction *= -1
	sprite.flip_h = (direction < 0)
	
	floor_ray.position.x = abs(floor_ray.position.x) * direction
	floor_ray.target_position.x = abs(floor_ray.target_position.x) * direction
	player_ray.target_position.x = abs(player_ray.target_position.x) * direction
	
	var collider = $AttackArea/CollisionShape2D
	collider.position.x = abs(collider.position.x) * direction
