extends Node

@onready var max_hp : int = 5
@onready var money : int = 200
@onready var mech_cost : int = 0

enum planets {NEOS, GAIA, TERRA, SELENE}
@onready var current_stage : int = 1
@onready var current_planet = planets.NEOS
@onready var planets_finished = []
@onready var planets_lost = []

@onready var post_fx_enabled = true

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

func save_run():
	var run_data : Dictionary = {
		"max_hp" : max_hp,
		"money" : money,
		"mech_cost" : mech_cost,
		"current_stage" : current_stage,
		"current_planet" : current_planet,
		"planets_finished" : planets_finished,
		"planets_lost" : planets_lost
	}
	if money >= 6000:
		print("Cannot save invalid game-state or tutorial run.")
		return
	var run_persistence_path = "user://mechteam_run.tres"
	var run_persistence_file = FileAccess.open(run_persistence_path, FileAccess.WRITE)
	run_persistence_file.store_var(run_data)
	run_persistence_file.close()
	print("Run has been saved.")

func load_run():
	var run_persistence_path = "user://mechteam_run.tres"
	var run_persistence_file = FileAccess.open(run_persistence_path, FileAccess.READ)
	if not run_persistence_file:
		print("No saved run found!")
		return
	var run_data : Dictionary = run_persistence_file.get_var()
	if run_data:
		max_hp = run_data.get("max_hp")
		money = run_data.get("money")
		mech_cost = run_data.get("mech_cost")
		current_stage = run_data.get("current_stage")
		current_planet = run_data.get("current_planet")
		planets_finished = run_data.get("planets_finished")
		planets_lost = run_data.get("planets_lost")
		print("Run has been loaded.")
	else:
		print("No saved run found!")

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
