extends Enemy
class_name Boss

@export var speed: float = 50.0
@export var gravity: float = 900.0
@export var jump_force: float = 200
@export var normal_texture: Texture2D
@export var attack_texture: Texture2D
@export var middle_point: Node2D
@export var prize_container: Node2D
@export var win_screen_container: Node2D

@export var attack_duration: float = 8
@export var idle_duration: float = 3
@export var falling_spikes_duration: float = 5

@onready var floor_ray = $FloorDetector
@onready var player_ray = $PlayerDetector
@onready var sprite = $Sprite2D
@onready var item_list: ItemList = $"../Camera2D/ItemList"

@export var jump_chance: float = 0.3  # 0.0 to 1.0
@export var direction_change_interval: float = 2.0

var enabled: bool = false

var move_timer: float = 0.0
var phase_timer: float = 0.0
var phase_do_setup: bool = true

var direction = 1
var already_attacked = false

#region Phase.BULLET_HELL
var bullet_amount = 100
var bullet_delay = 0.04
var bullet_delay_reset = 0.04
#endregion

enum Phase {
	IDLE,
	SWORD_EXTEND,
	BULLET_HELL,
	FALLING_SPIKES,
	
	Length
}
var phase: Phase = Phase.IDLE
var phases: Array[Callable] = []

func init():
	$HoldingSword.visible = false
	
	phases = [
		phase_idle,
		phase_attack,
		phase_bullet_hell,
		phase_falling_spikes
	]
	set_phase(Phase.IDLE)

func _physics_process(delta):
	super._physics_process(delta)
	
	if not enabled:
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	velocity.x = direction * speed
	move_and_slide()
	
	move_timer -= delta
	if move_timer <= 0.0:
		move_timer = direction_change_interval + randf_range(-0.5, 0.5)
		# Jumping seems bugged...
		#if randf() < jump_chance and is_on_floor():
			#velocity.y = -jump_force
		#else:
			#flip_direction()
		flip_direction()
	
	if is_on_wall():
		flip_direction()
	
	phases[phase].call(delta)

func set_phase(new_phase: Phase):
	if not enabled:
		return
	
	phase_do_setup = true
	phase = new_phase

func next_phase():
	swords_disengage() # Just to be sure
	
	phase += 1
	
	# Phases "loop" or wraparound once the last phase is reached
	if phase == Phase.Length:
		phase = Phase.IDLE
	
	set_phase(phase)

#region Phases
func phase_idle(_delta: float):
	if phase_do_setup:
		phase_do_setup = false
		
		if normal_texture:
			sprite.texture = normal_texture
		swords_disengage()
		await get_tree().create_timer(idle_duration).timeout
		next_phase()

func phase_attack(_delta: float):
	if phase_do_setup:
		phase_do_setup = false
		
		already_attacked = false
		if attack_texture:
			sprite.texture = attack_texture
		swords_extend()
		await get_tree().create_timer(attack_duration).timeout
		next_phase()
	
func phase_bullet_hell(delta: float):
	if phase_do_setup:
		phase_do_setup = false
		
		bullet_amount = 300
	
	bullet_delay -= delta
	
	if bullet_delay <= 0:
		var new_bullet = Util.scene_instantiate(PreloadManager.boss_bullet, global_position)
		new_bullet.direction = randi_range(1, 360)
		
		if bullet_amount <= 0:
			next_phase()
	
		bullet_amount -= 1
		bullet_delay = bullet_delay_reset

func phase_falling_spikes(_delta: float):
	if phase_do_setup:
		phase_do_setup = false
		
		for spike in get_tree().get_nodes_in_group("boss_spike"):
			spike.prepare_fall()
		
		await get_tree().create_timer(falling_spikes_duration).timeout
		next_phase()
#endregion

func swords_extend():
	$HoldingSword.visible = true
	for sword in get_tree().get_nodes_in_group("boss_sword"):
		sword.middle_point = middle_point
		sword.extend()

func swords_disengage():
	$HoldingSword.visible = false
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
	
func hurt(received_damage):
	super.hurt(received_damage)
	
	if health <= 0:
		swords_disengage()
		prize_container.activate()
		win_screen_container.activate()
	
