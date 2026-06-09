extends Enemy
class_name Boss

@export var speed: float = 50.0
@export var gravity: float = 900.0
@export var attack_duration: float = 10
@export var jump_force: float = 200
@export var normal_texture: Texture2D
@export var attack_texture: Texture2D
@export var middle_point: Node2D

@onready var floor_ray = $FloorDetector
@onready var player_ray = $PlayerDetector
@onready var sprite = $Sprite2D
@export var jump_chance: float = 0.3  # 0.0 to 1.0
@export var direction_change_interval: float = 2.0
@export var attack_interval: float = 8.0

var move_timer: float = 0.0
var phase_timer: float = 0.0

var direction = 1
var already_attacked = false

enum Phase { IDLE, SWORD_EXTEND }
var phase: Phase = Phase.IDLE
var phases: Array[Callable] = []

func _ready():
	phases = [phase_idle, phase_attack]

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	phase_timer -= delta
	if phase_timer <= 0.0:
		if phase == Phase.IDLE:
			set_phase(Phase.SWORD_EXTEND)
		else:
			set_phase(Phase.IDLE)
		phase_timer = attack_interval
	
	phases[phase].call(delta)

func phase_idle(delta: float):
	velocity.x = direction * speed
	move_and_slide()
	
	move_timer -= delta
	if move_timer <= 0.0:
		move_timer = direction_change_interval + randf_range(-0.5, 0.5)
		if randf() < jump_chance and is_on_floor():
			velocity.y = -jump_force
		else:
			flip_direction()
	
	if is_on_wall():
		flip_direction()

func phase_attack(_delta: float):
	velocity.x = 0
	move_and_slide()

func set_phase(new_phase: Phase):
	phase = new_phase
	match phase:
		Phase.IDLE:
			if normal_texture:
				sprite.texture = normal_texture
			swords_disengage()
		Phase.SWORD_EXTEND:
			already_attacked = false
			if attack_texture:
				sprite.texture = attack_texture
			swords_extend()
			do_attack()

func do_attack():
	if player_in_focus and not already_attacked:
		player_in_focus.hurt(damage)
		already_attacked = true
	await get_tree().create_timer(attack_duration).timeout
	set_phase(Phase.IDLE)

func swords_extend():
	for sword in get_tree().get_nodes_in_group("boss_sword"):
		sword.middle_point = middle_point
		sword.extend()

func swords_disengage():
	for sword in get_tree().get_nodes_in_group("boss_sword"):
		sword.disengage()
		
func flip_direction():
	direction *= -1
	sprite.flip_h = (direction < 0)
	floor_ray.position.x = abs(floor_ray.position.x) * direction
	floor_ray.target_position.x = abs(floor_ray.target_position.x) * direction
	player_ray.target_position.x = abs(player_ray.target_position.x) * direction
	var collider = $AttackArea/CollisionShape2D
	collider.position.x = abs(collider.position.x) * direction
