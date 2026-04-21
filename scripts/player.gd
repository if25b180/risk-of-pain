extends CharacterBody2D

@onready var animation = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var jump_sfx: AudioStreamPlayer2D = $jump_SFX
@onready var walk_sfx: AudioStreamPlayer2D = $walk_SFX


@export var speed := 200.0
@export var gravity := 900.0
@export var jump_force := -300.0

var was_on_floor := false


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		animation.play("p_jump")
		jump_sfx.play()
	
	var direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.x = direction * speed
	
	move_and_slide()
	
	if direction != 0:
		sprite.flip_h = direction < 0
		
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
