extends CanvasLayer

@export var light_pos : Vector2 = Vector2(0.405, 0.135)
@export var exposure : float = 0.065
@export var decay : float = 0.915
@export var density : float = 0.3
@export var weight : float = 0.32
@export var samples : int = 25
@export var threshold : float = 0.106

@onready var god_rays: ColorRect = $GodRays

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	if get_parent().has_meta("custom_postfx"):
		var vars = get_parent().get_meta("custom_postfx")
		light_pos = Vector2(vars[0], vars[1])
		exposure = vars[2]
		decay = vars[3]
		density = vars[4]
		weight = vars[5]
		samples = vars[6]
		threshold = vars[7]
	elif get_parent().has_node("Background"):
		if get_parent().get_node("Background").has_meta("custom_postfx"):
			print("herehjere")
			var vars = get_parent().get_node("Background").get_meta("custom_postfx")
			light_pos = Vector2(vars[0], vars[1])
			exposure = vars[2]
			decay = vars[3]
			density = vars[4]
			weight = vars[5]
			samples = vars[6]
			threshold = vars[7]
	god_rays.set_instance_shader_parameter("light_pos", light_pos)
	god_rays.set_instance_shader_parameter("exposure", exposure)
	god_rays.set_instance_shader_parameter("decay", decay)
	god_rays.set_instance_shader_parameter("density", density)
	god_rays.set_instance_shader_parameter("weight", weight)
	god_rays.set_instance_shader_parameter("samples", samples)
	god_rays.set_instance_shader_parameter("threshold", threshold)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not PlayerData.post_fx_enabled:
		hide()
	else:
		show()
