extends Node

@onready var max_hp : int = 5
@onready var money : int = 200
@onready var mech_cost : int = 0

enum planets {NEOS, GAIA, TERRA, SELENE}
@onready var current_stage : int = 1
@onready var current_planet = planets.NEOS
@onready var planets_finished = []
@onready var planets_lost = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

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
