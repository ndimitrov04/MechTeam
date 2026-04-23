extends Node

@onready var max_hp : int = 5
@onready var money : int = 200
@onready var mech_cost : int = 0

enum planets {NEOS, GAIA, TERRA, SELENE}
@onready var current_stage : int = 1
@onready var current_planet = planets.NEOS
@onready var planets_finished = []
@onready var planets_lost = []

@onready var terrain_test : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_terrain_test"):
		do_terrain_test()
		

func save_data():
	pass

func load_data():
	pass

func reset():
	max_hp = 5
	money = 200
	mech_cost = 0
	current_stage = 1
	current_planet = planets.NEOS
	planets_finished.clear()
	planets_lost.clear()

func do_terrain_test():
	terrain_test = true
	
	var affirmer = AudioStreamPlayer.new()
	affirmer.stream = load("uid://rf8mda10gl8x")
	add_child(affirmer)
	affirmer.play()
	await affirmer.finished
	affirmer.queue_free()
