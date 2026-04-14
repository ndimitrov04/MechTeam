extends Control

@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var planets: Control = $Parallax2D55/Planets

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for planet in planets.get_children():
		if PlayerData.planets_finished.has(planet.get_meta("planet_number")):
			planet.set_meta("finished", true)
			planet.modulate = Color.GREEN
			planet.self_modulate = Color.LIGHT_GRAY
			planet.material.set_shader_parameter("color", Color.LIGHT_GREEN)
			planet.disabled = true
			if PlayerData.planets_lost.has(planet.get_meta("planet_number")):
				planet.set_meta("lost", true)
				planet.modulate = Color.DARK_RED
				planet.material.set_shader_parameter("color", Color.DARK_SLATE_GRAY)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	camera_2d.set_position(get_global_mouse_position() * 0.1)
	
func _on_neos_pressed() -> void:
	PlayerData.current_planet = PlayerData.planets.NEOS
	get_tree().change_scene_to_file("res://Scenes/mech_builder.tscn")

func _on_gaia_pressed() -> void:
	PlayerData.current_planet = PlayerData.planets.GAIA
	get_tree().change_scene_to_file("res://Scenes/mech_builder.tscn")

func _on_terra_pressed() -> void:
	PlayerData.current_planet = PlayerData.planets.TERRA
	get_tree().change_scene_to_file("res://Scenes/mech_builder.tscn")

func _on_selene_pressed() -> void:
	PlayerData.current_planet = PlayerData.planets.SELENE
	get_tree().change_scene_to_file("res://Scenes/mech_builder.tscn")
