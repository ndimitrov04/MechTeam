extends Node

# Paths only (no preload, no load at init)
const PATHS := {
	"menu": "res://SCENES/menu.tscn",
	"main": "res://SCENES/main.tscn",
	"mech_builder": "res://SCENES/mech_builder.tscn",
	"planet_selector": "res://SCENES/planet_selector.tscn"
}

# Loaded SCENES cache
var SCENES : Dictionary = {}

# Track what is currently loading
var loading : Dictionary = {}

func _ready():
	# Start background loading at game start
	for key in PATHS.keys():
		_request_load(key)

func is_ready(key: String) -> bool:
	return SCENES.has(key)

func _request_load(key: String) -> void:
	if loading.has(key) or SCENES.has(key):
		return

	var path = PATHS[key]
	loading[key] = path
	ResourceLoader.load_threaded_request(path)

func _process(_delta: float) -> void:
	if loading.is_empty():
		return

	var to_remove = []

	for key in loading.keys():
		var path = loading[key]

		var status = ResourceLoader.load_threaded_get_status(path)

		if status == ResourceLoader.THREAD_LOAD_LOADED:
			SCENES[key] = ResourceLoader.load_threaded_get(path)
			to_remove.append(key)

		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Failed to load scene: " + path)
			to_remove.append(key)

	for key in to_remove:
		loading.erase(key)
