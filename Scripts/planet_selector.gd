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

@onready var comms: Control = $Comms

@onready var person_name: Label = $Comms/Panel/PictureData/PersonName
@onready var person_picture: TextureRect = $Comms/Panel/PictureData/Picture
@onready var message_field: RichTextLabel = $Comms/Panel/MessageData/Message
@onready var data_field: RichTextLabel = $Comms/Panel/ReceivedData/Data

@onready var god_rays: ColorRect = $GodRays

@onready var selected_planet 

const planet_lores = [
	"Dubbed as a planet of hope, Neos was the first bastion of the newly free world in a series of planets whose politics would be controlled by cold but fair steel - Scopos - a super AI whose only task was to optimize the quality of life of its people. Once created, Scopos' architecture would be completely unchangeable for even its own creators to prevent its manipulation by bad actors.\n\nFor close to a century this planet was an utopia and the home to a thriving human community. All of this was destroyed 10 years ago with the rise of a group known as Anima, who destroyed Scopos for an undisclosed reason.\n\nCurrently, this planet is being assaulted by unknown forces. The citizens need your help.\n\nNote: Starter enemy types; Steep terrain, small mechs preferable.",
	"???",
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

const planet_sprites = [
	preload("res://CustomResources/sprite_frames/neos.tres"),
	preload("res://CustomResources/sprite_frames/gaia.tres"),
	preload("res://CustomResources/sprite_frames/terra.tres"),
	preload("res://CustomResources/sprite_frames/selene.tres")
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalMusic.queue_track("res://Audio/Music/Lost signal main theme.mp3", 2)
	for planet in planets.get_children():
		planet.material.set_shader_parameter("color", Color.WHITE)
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
	if PlayerData.current_planet != null:
		comms.show()
		if PlayerData.current_planet in PlayerData.planets_lost:
			match PlayerData.current_planet:
				PlayerData.planets.NEOS:
					load_message_data(
						"Sarge1 (needs name)",
						preload("res://Images/Characters/Portraits/Sarge.png"),
						"Damn it, we failed! The unknown foes killed Talanthir and then left the planet. It appears the attack was not against the planet, but against him specifically? Still, this was a massive failure! Many Neos soldiers and civillians died in the attacks. We must exercise extreme caution when planning future missions. Failure is NOT an option when so many lives are at stake!",
						"NULL",
						true
					)
				PlayerData.planets.TERRA:
					load_message_data(
						"Draven Korthak",
						preload("res://Images/Characters/Portraits/TerraProtector.png"),
						"YOU PATHETIC COWARDLY SCUM! We managed to drive Anima off of the planet, however our subterranian infrastructure was destroyed! Thank the heavens they did not massacare our citizens! This infrastructure was built by humans and aliens alike for generations - without it - not only has our history been erased, but the lives of our citizens have been completely ruined. We cannot rebuild so quickly and we do not have the resources required to do so after this war! Your actions will result in more than a billion projected deaths due to the rapid increase of poverty, crime, homelessness and unemployment! Consider yourselves an enemy to Terra! Death will come for you soon...",
						"Recieved 1 datalog: Story: 2188-2195",
						true
					)
					unlock_datalog(0)
				PlayerData.planets.SELENE:
					load_message_data(
						"Calyx (?)",
						preload("res://Images/Characters/Portraits/SeleneProtector2.png"),
						"You will be severely sorry for your decisions.",
						"Received 1 datalog: Story: 2165-2184",
						true
					)
					unlock_datalog(0)
				PlayerData.planets.GAIA:
					load_message_data(
						"Sarge2 (needs name)",
						preload("res://Images/Characters/Portraits/Sarge2.png"),
						"They destroyed the entire planet! There is nothing left... I - I can't believe this... Who were these people and what could they possibly have gotten out of the annihilation of an entire planet? I... I feel sick, I'm taking a few days off, you know how to use the mechbuilding systems if you need to...",
						"NULL",
						true
					)
		else:
			match PlayerData.current_planet:
				PlayerData.planets.NEOS:
					load_message_data(
						"Oryx Talanthir",
						preload("res://Images/Characters/Portraits/NeosProtector.png"),
						"You have successfuly completed your mission. The citizens of Neos thank you greatly. We might not have survived without your help. Your compensation is waiting for you. If you ever need any assistance with anything, we will be ready to lend you a hand.",
						"Found 1 data log in enemy wreckage: Story: 2112 - 2127 - 2165",
						true
					)
					unlock_datalog(0)
				PlayerData.planets.TERRA:
					load_message_data(
						"Draven Korthak",
						preload("res://Images/Characters/Portraits/TerraProtector.png"),
						"Excellent job merc! You have earned your pay in full. I have a little bonus for you as well. I know that there are more calls out there for peacekeeping services connected to Anima. It seems that they are a universal enemy of the entire solar system. Well - we datamined some information from captured enemy mechs. Here's what our scientists put together, it may be of help against your future foes. These logs seem to be connected to Anima's actions around 100-200 years ago. We believe they are connected to the history of this planet, but we could not find any more records. Anyway, farewell and good luck on your future missions.",
						"Recieved 2 datalogs: Story: 2080-2112; Story: 2188 - 2195",
						true
					)
					unlock_datalog(0)
				PlayerData.planets.SELENE:
					load_message_data(
						"Calyx (?)",
						preload("res://Images/Characters/Portraits/SeleneProtector2.png"),
						"You have succesfully completed your mission. Here is your reward.",
						"Received 1 datalog: Story: 2184-2188",
						true
					)
					unlock_datalog(0)
				PlayerData.planets.GAIA:
					load_message_data(
						"Sarge2 (needs name)",
						preload("res://Images/Characters/Portraits/Sarge2.png"),
						"We recieved no word from Vesper, but guess what just arrived? A space probe loaded with an enormous amount of digital currency and a strange datalog with data about a planet named Earth from around 200 years ago.",
						"Received 1 datalog: Story: 2070-2080",
						true
					)
					unlock_datalog(0)
					
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	camera_2d.set_position(get_global_mouse_position() * 0.2)
	if not PlayerData.post_fx_enabled:
		god_rays.hide()

func unlock_datalog(number):
	pass

@onready var accept_status: Panel = $Comms/Panel/AcceptStatus
func load_message_data(protector_name, picture, message, data, hide_accept = false) -> void:
	comms.show()
	if hide_accept:
		accept_status.hide()
	else:
		accept_status.show()
	person_name.text = protector_name
	person_picture.texture = picture
	message_field.text = message
	data_field.text = data

func _on_neos_pressed() -> void:
	selected_planet = PlayerData.planets.NEOS
	load_message_data(
		"Oryx Talanthir",
		preload("res://Images/Characters/Portraits/NeosProtector.png"),
		"Salutations gentlemen. I am Oryx Talanthir, the ruler of planet Neos. Our home is being assaulted by unknown, unmarked foes. Years ago, this planet used to be an utopia ruled by a super-AI, but a paramillitary group known as Anima attacked us and destroyed it. Now we are left without protection and must fight our enemies with people, not drones. We have sustained heavy casualties and are in desperate need of support. Your mission is to take down the base of operations of our foes.",
		"NULL"
	)

func _on_gaia_pressed() -> void:
	selected_planet = PlayerData.planets.GAIA
	load_message_data(
		"Vesper Halcynt",
		preload("res://Images/Characters/Portraits/GaiaProtector.png"),
		"I am Vesper Halcynt. I request armed reinforcements. Our mothership planet Gaia is under attack. We have peacefully lived in Gitil for 70 years. Extrasolar foes have attacked our planet. You must destroy them. I am Vesper Halcynt. I request armed reinforcements. Our mothership planet Gaia is under attack. We have peacefully lived in Gitil for 70 years. Extrasolar foes have attacked our planet. You must destroy them. I am Vesper Halcynt. I request armed reinforcements. Our mothership planet Gaia is under attack. We have peacefully lived in Gitil for 70 years. Extrasolar foes have attacked our planet. You must destroy them. I am Vesper Halcynt. I request armed reinforcements. Our mothership planet Gaia is under attack. We have peacefully lived in Gitil for 70 years. Extrasolar foes have attacked our planet. You must destroy them. I am Vesper Halcynt. I request armed reinforcements. Our mothership planet Gaia is under attack. We have peacefully lived in Gitil for 70 years. Extrasolar foes have attacked our planet. You must destroy them. I am Vesper Halcynt. I request armed reinforcements. Our mothership planet Gaia is under attack. We have peacefully lived in Gitil for 70 years. Extrasolar foes have attacked our planet. You must destroy them...",
		"NULL"
	)

func _on_terra_pressed() -> void:
	selected_planet = PlayerData.planets.TERRA
	load_message_data(
		"Draven Korthak",
		preload("res://Images/Characters/Portraits/TerraProtector.png"),
		"Greetings. My name is Draven Korthak. I am the head of the terran defense force. I requested reinforcements on all channels and it appears that you lot got my message. Our enemy - Anima group - is preparing to assault AX13C. That is the gateway between the surface of our planet, where most of our automated farms are, and our subterranian cities. We have been in quite the predicament for a few months, with no real way to guarantee food supplies without these farms. We have devised a plan to launch a counterattack and drive Anima out of the planet. This plan however will require all of our forces, leaving our citizens unprotected. Terra's mantle is unbreakable, so the only entrypoint to the inner subterranian cities is the gate at AX13C. You are to protect that gate with your life until we destroy Anima's mech spawners on the surface. Great fortunes await you if you succeed. ",
		"NULL"
	)

func _on_selene_pressed() -> void:
	selected_planet = PlayerData.planets.SELENE
	load_message_data(
		"Calyx (?)",
		preload("res://Images/Characters/Portraits/SeleneProtector2.png"),
		"Who I am is of no concern to you. Just call me Calyx. I need you to terminate the lives of a bunch of colonizers in the Gitil solar system. A space pirate company known as GEOS started digging for something on a seemingly uninhabited planet 15 years ago. It turned out that this planet - Selene - is a living creature. Not only that, on it, there is apparently a small indigenous alien population there as well. I want the planet not destroyed, the aliens alive and anyone from GEOS dead. It is none of your concern why. The less questions you ask, the higher the chance you'll live to see tommorow. You will be rewarded shortly after completing your mission. Do not disappoint me.",
		"NULL"
	)

	
@onready var planet_sprite: AnimatedSprite2D = $PlanetInfo/Panel/PictureData/Sprite
func load_planet_data(planet_enum):
	planet_name.text = planet_names[planet_enum]
	planet_stats.text = planet_data[planet_enum]
	planet_lore.text = planet_lores[planet_enum]
	planet_picture.texture = planet_pictures[planet_enum]
	planet_sprite.sprite_frames = planet_sprites[planet_enum]
	planet_sprite.play("default")
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


func _on_accept_pressed() -> void:
	PlayerData.current_planet = selected_planet
	IndieBlueprintSceneTransitioner.transition_to(
		SceneCache.SCENES.get("mech_builder"), 
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("000418")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
		}
	)

func _on_close_pressed() -> void:
	comms.hide()

func _on_deny_pressed() -> void:
	comms.hide()
