extends Control

@onready var player = $"../../../Player"
@onready var main = $"../../.."

var current_module = null

var quicktime_arrow = preload("res://Scenes/Minigames/quick_time_arrow.tscn")
var precission_target = preload("res://Scenes/Minigames/precission_target.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn_minigame(game_object):
	var game_scene = game_object.instantiate()
	add_child(game_scene)
	game_scene.start()

func start_minigame(mname : String, controlled_module):
	print("Minigames: " + controlled_module.name)
	current_module = controlled_module
	print("current_module: " + current_module.name)
	match mname:
		"quicktime_arrow":
			spawn_minigame(quicktime_arrow)
		"precission_target":
			spawn_minigame(precission_target)
		_:
			print("No such minigame exists.")

func end_minigame():
	current_module = null
	#get_child(0).queue_free()

func win():
	print(current_module.name + " goes PEWPEW!!!")
	current_module.engage()
	main.static_ui.display_minigame_result(true)

func lose():
	main.static_ui.display_minigame_result(false)
