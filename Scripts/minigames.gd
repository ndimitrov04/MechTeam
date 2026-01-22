extends Control

@onready var player = $"../../../Player"

var current_weapon = null

var quicktime_arrow = preload("res://Scenes/Minigames/quick_time_arrow.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn_minigame(game_object):
	var game_scene = game_object.instantiate()
	add_child(game_scene)
	game_scene.start()

func start_minigame(mname : String, controlled_weapon):
	print("Minigames: " + controlled_weapon.name)
	current_weapon = controlled_weapon
	print("Current_weapon: " + current_weapon.name)
	match mname:
		"quicktime_arrow":
			spawn_minigame(quicktime_arrow)
		_:
			print("No such minigame exists.")

func end_minigame():
	current_weapon = null
	get_child(0).queue_free()

func win():
	print(current_weapon.name + " goes PEWPEW!!!")
	current_weapon.shoot()
	pass
