extends Control

@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var planets: Control = $Parallax2D55/Planets
@onready var neos: TextureButton = $Parallax2D55/Planets/Neos
@onready var gaia: TextureButton = $Parallax2D55/Planets/Gaia
@onready var terra: TextureButton = $Parallax2D55/Planets/Terra
@onready var selene: TextureButton = $Parallax2D55/Planets/Selene

@onready var planet_info: Control = $PlanetInfo

@onready var planet_name: Label = $PlanetInfo/Panel/MainData/PlanetName
@onready var planet_stats: Label = $PlanetInfo/Panel/StatsData/PlanetStats
@onready var planet_lore: Label = $PlanetInfo/Panel/LoreData/PlanetLore
@onready var planet_picture: TextureRect = $PlanetInfo/Panel/PictureData/Picture
@onready var status: Label = $PlanetInfo/Panel/StatusData/Status

const planet_lores = [
	"Neos lore",
	"Gaia lore",
	"Terra lore",
	"Selene lore"
]

const planet_names = [
	"NEOS",
	"GAIA",
	"TERRA",
	"SELENE"
]

const planet_data = [
	"Climate: -
	Terrain: -
	Hostility: -
	Atmosphere: -
	Difficulty: -",
	"Climate: -
	Terrain: -
	Hostility: -
	Atmosphere: -
	Difficulty: -",
	"Climate: -
	Terrain: -
	Hostility: -
	Atmosphere: -
	Difficulty: -",
	"Climate: -
	Terrain: -
	Hostility: -
	Atmosphere: -
	Difficulty: -",
]

const planet_pictures = [
	preload("res://Images/Planets/neos.png"),
	preload("res://Images/Planets/gaia.png"),
	preload("res://Images/Planets/terra.png"),
	preload("res://Images/Planets/selene.png")
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalMusic.queue_track("res://Audio/Music/Lost signal main theme.mp3", 2)
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
	camera_2d.set_position(get_global_mouse_position() * 0.2)
	
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

func load_planet_data(planet_enum):
	planet_name.text = planet_names[planet_enum]
	planet_stats.text = planet_data[planet_enum]
	planet_lore.text = planet_lores[planet_enum]
	planet_picture.texture = planet_pictures[planet_enum]
	status.text = "UNSAFE"
	status.modulate = Color.ORANGE
	if planets.get_child(planet_enum).get_meta("finished"):
		status.text = "SAFE"
		status.modulate = Color.GREEN
		if planets.get_child(planet_enum).get_meta("lost"):
			status.text = "LOST"
			status.modulate = Color.RED

func _on_neos_mouse_entered() -> void:
	planet_info.show()
	load_planet_data(PlayerData.planets.NEOS)
	if neos.get_meta("finished"):
		return
	neos.self_modulate = Color(1.3, 1.3, 1.3)

func _on_neos_mouse_exited() -> void:
	planet_info.hide()
	if neos.get_meta("finished"):
		return
	neos.self_modulate = Color(1.0, 1.0, 1.0)

func _on_gaia_mouse_entered() -> void:
	planet_info.show()
	load_planet_data(PlayerData.planets.GAIA)
	if gaia.get_meta("finished"):
		return
	gaia.self_modulate = Color(1.3, 1.3, 1.3)

func _on_gaia_mouse_exited() -> void:
	planet_info.hide()
	if gaia.get_meta("finished"):
		return
	gaia.self_modulate = Color(1.0, 1.0, 1.0)

func _on_terra_mouse_entered() -> void:
	planet_info.show()
	load_planet_data(PlayerData.planets.TERRA)
	if terra.get_meta("finished"):
		return
	terra.self_modulate = Color(1.3, 1.3, 1.3)

func _on_terra_mouse_exited() -> void:
	planet_info.hide()
	if terra.get_meta("finished"):
		return
	terra.self_modulate = Color(1.0, 1.0, 1.0)

func _on_selene_mouse_entered() -> void:
	planet_info.show()
	load_planet_data(PlayerData.planets.SELENE)
	if selene.get_meta("finished"):
		return
	selene.self_modulate = Color(1.3, 1.3, 1.3)

func _on_selene_mouse_exited() -> void:
	planet_info.hide()
	if selene.get_meta("finished"):
		return
	selene.self_modulate = Color(1.0, 1.0, 1.0)
