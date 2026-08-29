extends Camera2D

# Based of the 3.x KidsCanCode implementation -> 
# https://kidscancode.org/godot_recipes/3.x/2d/screen_shake/index.html

@export var decay := 0.8 #How quickly shaking will stop [0,1].
@export var max_offset := Vector2(100,75) #Maximum displacement in pixels.
@export var max_roll := 0.1 #Maximum rotation in radians (use sparingly).
@export var noise : FastNoiseLite #The source of random values.

var noise_y = 0 #Value used to move through the noise

var trauma := 0.0 #Current shake strength
var trauma_pwr := 2 #Trauma exponent. Use [2,3]

var bonus_impact = 0 # Manual override for extreme screenshake

func _ready():
	randomize()
	noise.seed = randi()

func add_trauma(amount : float):
	trauma = min(trauma + amount, 1.0)
	trauma = clampf(trauma, 0, 0.7 + bonus_impact)

func slide_camera(direction_to : int):
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	match direction_to:
		-1:
			tween.tween_property(self, "position", Vector2(-300 / zoom.x, 0), 0.5)
		0:
			tween.tween_property(self, "position", Vector2(0, 0), 0.5)
		1:
			tween.tween_property(self, "position", Vector2(300 / zoom.x, 0), 0.5)

func zoom_change(new_zoom):
	if PlayerData.motion_sickness_mode:
		self.zoom = new_zoom
	else:
		self.zoom = self.zoom.lerp(new_zoom, 1 - exp(-5 * get_process_delta_time()))

const edge_threshold = 200
func _process(delta):
	if not PlayerData.motion_sickness_mode:
		var mouse_position = get_viewport().get_mouse_position()
		var viewport_width = get_viewport_rect().size.x
		var is_near_left_edge = mouse_position.x <= edge_threshold
		var is_near_right_edge = mouse_position.x >= viewport_width - edge_threshold
		if is_near_left_edge:
			slide_camera(-1)
		elif is_near_right_edge:
			slide_camera(1)
		else:
			slide_camera(0)

		if trauma > 1.4:
			trauma = 1.4
		if trauma:
			trauma = max(trauma - decay * delta, 0)
			shake()
		elif offset.x != 0 or offset.y != 0 or rotation != 0:
			lerp(offset.x,0.0,1)
			lerp(offset.y,0.0,1)
			lerp(rotation,0.0,1)

func shake(): 
	var amt = pow(trauma, trauma_pwr)
	noise_y += 1
	rotation = max_roll * amt * noise.get_noise_2d(0, noise_y)
	offset.x = max_offset.x * amt * noise.get_noise_2d(1000, noise_y)
	offset.y = max_offset.y * amt * noise.get_noise_2d(2000, noise_y)
