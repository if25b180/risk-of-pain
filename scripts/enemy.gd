extends CharacterBody2D

@export var speed := 50.0
@export var gravity := 900.0
@export var attack_duration := 0.5

@export var normal_texture: Texture2D
@export var attack_texture: Texture2D

var direction := 1 
var is_attacking := false

@onready var floor_ray = $RayCast2D
@onready var player_ray = $PlayerDetector
@onready var sprite = $Sprite2D

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	check_for_player()

	if not floor_ray.is_colliding() or is_on_wall():
		flip_direction()

	velocity.x = direction * speed
	move_and_slide()

func check_for_player():
	if player_ray.is_colliding():
		var collider = player_ray.get_collider()
		if collider and collider.is_in_group("player"):
			start_attack()

func start_attack():
	print("angriff test")
	is_attacking = true
	
	if attack_texture:
		sprite.texture = attack_texture
	
	await get_tree().create_timer(attack_duration).timeout
	
	if normal_texture:
		sprite.texture = normal_texture
		
	is_attacking = false

func flip_direction():
	direction *= -1
	sprite.flip_h = (direction < 0)
	
	floor_ray.position.x = abs(floor_ray.position.x) * direction
	floor_ray.target_position.x = abs(floor_ray.target_position.x) * direction
	
	player_ray.target_position.x = abs(player_ray.target_position.x) * direction
	
	$AttackArea.position.x = abs($AttackArea.position.x) * direction

func _on_attack_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
