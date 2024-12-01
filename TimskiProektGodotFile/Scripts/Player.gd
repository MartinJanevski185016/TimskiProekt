extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = -600.0
const ACCELERATION = 1200.0
const AIR_ACCELERATION = 600.0
const FRICTION = 2000.0
const AIR_RESISTANCE = 1500.0
var air_jump = false
var just_wall_jumped = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $"CoyoteJump Timer"

func _physics_process(delta):
	apply_gravity(delta)
	handle_wall_jump()
	handle_jump()
	var input_axis = Input.get_axis("walk_left", "walk_right")
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	just_wall_jumped = false
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
func handle_wall_jump():
	if not is_on_wall_only(): return
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("jump") and is_on_wall_only():
		velocity.x = wall_normal.x * SPEED
		velocity.y = JUMP_VELOCITY
		just_wall_jumped = true
	
func handle_jump():
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		air_jump = true
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y <  JUMP_VELOCITY / 2:
			velocity.y = JUMP_VELOCITY / 2
			
		if Input.is_action_just_pressed("jump") and air_jump and not just_wall_jumped:
			velocity.y = JUMP_VELOCITY * 0.8
			air_jump = false
			
func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x,  SPEED * input_axis,  ACCELERATION * delta)
		
func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x ,SPEED * input_axis, AIR_ACCELERATION * delta)

func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0,  FRICTION * delta)
		
func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, AIR_RESISTANCE * delta)

func update_animations(input_axis):
	if not is_on_floor(): 
		#flip direction if action pressed
		if(Input.is_action_pressed("walk_left") or Input.is_action_pressed("walk_right")):
			animated_sprite_2d.flip_h = (input_axis < 0)
	#jumping and walking
		if is_on_wall_only() and (Input.is_action_pressed("walk_left") or Input.is_action_pressed("walk_right")):
			animated_sprite_2d.play("wall_fall")
		#jump up
		elif velocity.y < 0.0:
			#handle double jump if too soon pressed
			if animated_sprite_2d.is_playing() and Input.is_action_just_pressed("jump"):
				animated_sprite_2d.stop()
				animated_sprite_2d.play("jump")
			animated_sprite_2d.play("jump")
		#falling
		elif velocity.y > 0.0:
			animated_sprite_2d.play("fall")
	
	elif is_on_floor() and input_axis !=0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("idle")

