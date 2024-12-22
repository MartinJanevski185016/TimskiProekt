extends TextureProgressBar

@onready var show_hide_timer = $"ShowHideTimer"
@onready var low_stamina_timer = $LowStaminaBarTimer
@export var jump_drain = 20.0
@export var dash_drain = 40.0
@export var wall_jump_drain = 15.0
var color = self.modulate

func _ready():
	modulate.a = 0
	value = 100
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_just_pressed('jump') or Input.is_action_just_pressed('dash_left') or Input.is_action_just_pressed('dash_right')):
		turn_visible()
		show_hide_timer.start()	
	if(show_hide_timer.is_stopped()):
		value += 1
	if value == 100:
		turn_invisible()
			
func turn_invisible():
	create_tween().tween_property(self, 'modulate:a', 0, 0.3)
	
func turn_visible():
	create_tween().tween_property(self, 'modulate:a', 1, 0.3)

func low_stamina_effect():
	position.x += 10
	create_tween().tween_property(self, 'modulate', Color.RED, 0.1)
	await get_tree().create_timer(0.1).timeout
	position.x -= 10
	create_tween().tween_property(self, 'modulate', color, 0.1)
	
func calculate_stamina(type):
	value -= type
	
func is_exhausted(type):
	return type > value	

func _on_show_hide_timer_timeout():
	show_hide_timer.stop()


func _on_low_stamina_bar_timer_timeout():
	low_stamina_timer.stop()
