extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = -600.0
const ACCELERATION = 1200.0
const FRICTION = 2000.0
const AIR_ACCELERATION = 600.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D

func _physics_process(delta):
	apply_gravity(delta)
	var input_axis = Input.get_axis("walk_left", "walk_right")
	handle_jump()
	handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	update_animations(input_axis)
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
func handle_jump():
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			
func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x,  SPEED * input_axis,  ACCELERATION * delta)

func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x , SPEED * input_axis, AIR_ACCELERATION * delta)
		
func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0,  FRICTION * delta)
		
func update_animations(input_axis):
	if not is_on_floor(): 
		#flip direction if action pressed
		if(Input.is_action_pressed("walk_left") or Input.is_action_pressed("walk_right")):
			animated_sprite_2d.flip_h = (input_axis < 0)	
		if velocity.y != 0.0:
			animated_sprite_2d.play("jump")
	elif is_on_floor() and input_axis !=0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("walk")	
	else:
		animated_sprite_2d.play("idle")
	
