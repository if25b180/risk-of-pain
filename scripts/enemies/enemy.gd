extends CharacterBody2D
class_name Enemy

@export var attack_area: Area2D

@export var health: float = 50
@export var damage: float = 15
@export var item_drop_chance_percent: int = 10

var player_in_focus = null
var max_health: float = health

#region SFX
@onready var hurt_enemy_sfx: AudioStreamPlayer2D = $Hurt_Enemy
#endregion

func _physics_process(_delta: float) -> void:
	var healthbar: ProgressBar = $Healthbar
	if healthbar:
		healthbar.value = (health / max_health) * 100

func _ready():
	max_health = health
	attack_area.connect("body_entered", _on_attack_area_body_entered)
	attack_area.connect("body_exited", _on_attack_area_body_exited)

func hurt(received_damage):
	health -= received_damage
	hurt_enemy_sfx.play()
	particle_hit_spawn()
	
	if health <= 0:
		if randi_range(0, 100) < item_drop_chance_percent:
			print(ItemPool.items)
			var dropped_item_scene = ItemPool.get_random_item()
			
			# TODO: This is only a workaround for Sprint 4:
			# Attempt to call function 'instantiate' in base 'null instance' on a null instancee
			if not dropped_item_scene:
				queue_free()
				return
				
			var dropped_item: Node2D = dropped_item_scene.instantiate()
			
			Util.get_world_root().add_child(dropped_item)
			dropped_item.global_position = global_position
		
		queue_free()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_focus = body

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_focus = null

func apply_fire(duration: float, dps: float) -> void:
	var remaining = duration
	while remaining > 0:
		await get_tree().create_timer(1.0).timeout
		hurt(dps)
		remaining -= 1.0

func apply_poison(dps: float) -> void:
	while is_instance_valid(self):
		await get_tree().create_timer(1.0).timeout
		hurt(dps)

func particle_hit_spawn():
	var new_particles: CPUParticles2D = PreloadManager.particle_hit.instantiate()
	Util.get_world_root().add_child(new_particles)
	var gravity = new_particles.gravity.x
	new_particles.gravity = Vector2.ZERO
	
	var player = Util.get_player()
	var dir = (player.global_position - global_position).normalized()
	# Player is above/below enemy
	if abs(dir.y) > abs(dir.x):
		if dir.y < 0:
			new_particles.gravity.y = gravity
		else:
			new_particles.gravity.y = -gravity
	else: # Player is left/right of enemy
		if dir.x < 0:
			new_particles.gravity.x = gravity
		else:
			new_particles.gravity.x = -gravity

	new_particles.global_position = global_position
	new_particles.one_shot = true
	new_particles.emitting = true
	new_particles.finished.connect(new_particles.queue_free)
