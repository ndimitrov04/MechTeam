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
@onready var planet_lore: RichTextLabel = $PlanetInfo/Panel/LoreData/PlanetLore
@onready var planet_picture: TextureRect = $PlanetInfo/Panel/PictureData/Picture
@onready var status: Label = $PlanetInfo/Panel/StatusData/Status

@onready var god_rays: ColorRect = $GodRays

const planet_lores = [
	"Dubbed as a planet of hope, Neos was the first bastion of the newly free world in a series of planets whose politics would be controlled by cold but fair steel - Scopos - a super AI whose only task was to optimize the quality of life of its people. Once created, Scopos' architecture would be completely unchangeable for even its own creators to prevent its manipulation by bad actors.\n\nFor close to a century this planet was an utopia and the home to a thriving human community. All of this was destroyed 10 years ago with the rise of a group known as Anima, who destroyed Scopos for an undisclosed reason.\n\nCurrently, this planet is being assaulted by unknown forces. The citizens need your help.\n\nNote: Starter enemy types; Steep terrain, small mechs preferable.",
	"Gaia is a mining colony powered by its own ring, which consists of nuclear rock. Governed by shadow stakeholders, this place exists solely to generate profit for an unknown third party. It is full of paramillitary operators whose only job is to keep the mining operations going. This planet is uninhabited by civillians on paper, but our sources hint that there is an indigenous alien population which resides in a far corner of the planet.\n\nAn anonymous source has contacted us to warn of an impending attack by a rival group known as GEOS. If GEOS sets foot on Gaia, this will be the start of a resource war between them and the current government. Two corporate paramillitaries fighting is none of our concern, however, there are innocent souls on this planet who would be annihilated in the crossfire.\n\nStop GEOS at any cost!\n\nNote: Advanced enemy types. Harmful atmosphere! Do not leave mech!",
	"Terra is a fortress planet, home to billions of people and governed by an organization known as 'Liberty'. \n\nThis planet is currently under assault by the Anima group. Liberty has contacted us and are requesting backup at the underground checkpoint of AX13C - the third most inhabited city of the planet.\n\nAs always, Anima's motives are unknown. Nevertheless, one thing is clear: They have already destroyed one thriving planet, stop them from destroying another! \n\nNote: Only tough enemy types; Flat terrain; Take advantage of enemy self destruct buttons!",
	"Selene's existence is not well known outside of this solar system, its terrain is extremely rough and there is nothing of value on the planet. This is why it was an unoccupied haven of nature for up until 5 years ago. It is currently being colonized by GEOS for unknown reasons.\n\nGEOS is performing massive excavations at seemingly random locations on the planet. 2 weeks ago, spy satelites managed to capture pictures of the biggest excavation site. To the surprise of everyone, the planet's inner structure seemed to be biological! With its mantle being only an outer shell.\n\nA shadow client, presenting themselves as a magnanimous interplanetary nature preserver, wants us to stop GEOS from digging any deeper. We are one of many independent millitias who were hired for the job. Our task is to assault 3 strategic points, putting an end to all GEOS activity there.\n\nExpect extreme resistance and very rough terrain. Good luck!\n\nNote: All enemy types; Extreme terrain"
]

const planet_names = [
	"NEOS",
	"GAIA",
	"TERRA",
	"SELENE"
]

const planet_data = [
	"Climate: Warm
	Terrain: Steep
	Hostility: Low
	Atmosphere: Fair
	Difficulty: Easy",
	"Climate: Cold
	Terrain: Fair
	Hostility: Medium
	Atmosphere: Polluted
	Difficulty: Normal",
	"Climate: Subterranian
	Terrain: Flat
	Hostility: Brutal
	Atmosphere: Fair
	Difficulty: Hard",
	"Climate: Fair
	Terrain: Extreme
	Hostility: Severe
	Atmosphere: Fair
	Difficulty: Brutal",
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
	if not PlayerData.post_fx_enabled:
		god_rays.hide()
	
func _on_neos_pressed() -> void:
	PlayerData.current_planet = PlayerData.planets.NEOS
	IndieBlueprintSceneTransitioner.transition_to(
		SceneCache.SCENES.get("mech_builder"), 
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("000418")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
		}
	)

func _on_gaia_pressed() -> void:
	PlayerData.current_planet = PlayerData.planets.GAIA
	IndieBlueprintSceneTransitioner.transition_to(
		SceneCache.SCENES.get("mech_builder"), 
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("000418")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
		}
	)

func _on_terra_pressed() -> void:
	PlayerData.current_planet = PlayerData.planets.TERRA
	IndieBlueprintSceneTransitioner.transition_to(
		SceneCache.SCENES.get("mech_builder"), 
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("000418")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
		}
	)

func _on_selene_pressed() -> void:
	PlayerData.current_planet = PlayerData.planets.SELENE
	IndieBlueprintSceneTransitioner.transition_to(
		SceneCache.SCENES.get("mech_builder"), 
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("000418")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
		}
	)

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
	if selene.get_meta("finished"):
		return
	selene.self_modulate = Color(1.0, 1.0, 1.0)
