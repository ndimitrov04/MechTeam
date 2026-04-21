extends CanvasLayer

@onready var retry: Button = $MenuPanel/Retry
@onready var abandon_planet: Button = $MenuPanel/AbandonPlanet

func _ready() -> void:
	pass

func _unhandled_input(event):
	if event.is_action_pressed("menu"):
		if visible:
			hide()
			get_tree().paused = false
		elif not visible and get_tree().current_scene.name != "Menu":
			show()
			get_tree().paused = true

func _on_retry_pressed() -> void:
	hide()
	get_tree().paused = false
	PlayerData.money -= 15
	IndieBlueprintSceneTransitioner.transition_to(
		get_tree().current_scene.scene_file_path, 
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("55648C")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
		}
	)

func _on_abandon_planet_pressed() -> void:
	hide()
	get_tree().paused = false
	# Planetary stage; Abandoning a planet
	# automatically increases the stage level
	# to whichever stage the player would've
	# made it to if they hadn't abandoned it
	# Stage 3
	if (PlayerData.current_stage + 0) % 3 == 0:
		PlayerData.current_stage += 1
	# Stage 2
	elif (PlayerData.current_stage + 1) % 3 == 0:
		PlayerData.current_stage += 2
	# Stage 1
	elif (PlayerData.current_stage + 2) % 3 == 0:
		PlayerData.current_stage += 3
	PlayerData.planets_finished.append(PlayerData.current_planet)
	PlayerData.planets_lost.append(PlayerData.current_planet)
	IndieBlueprintSceneTransitioner.transition_to(
		"res://Scenes/planet_selector.tscn", 
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("55648C")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("000418")}
		}
	)

func _on_visibility_changed() -> void:
	if get_tree().current_scene.name == "Editor":
		retry.hide()
		abandon_planet.show()
	elif get_tree().current_scene.name == "Main":
		retry.show()
		abandon_planet.hide()
		if get_tree().current_scene.has_meta("main_gamemode"):
			abandon_planet.show()
	elif get_tree().current_scene.name == "PlanetSelector":
		retry.hide()
		abandon_planet.hide()
		
@onready var message: Label = $MenuPanel/Message
func _on_retry_mouse_entered() -> void:
	message.text = "NOTICE:\n\nRetrying a stage costs 15 money.\n\nYou can reset even\nif you don't have 15 money, but\nyou will go in-debt by doing this."
	message.show()
func _on_retry_mouse_exited() -> void:
	message.hide()

func _on_abandon_planet_mouse_entered() -> void:
	message.text = "WARNING!\n\nAbandoning a planet will result in you escaping with your life, but failing your planet objective.\n\nYou will get to choose another planet to go to, however you will never be able to return to this planet and complete its stages. Furthermore, the game's difficulty will still rise as if you have beaten all stages on this planet. You will probably not have the funds to upgrade your mech to match the upcoming challenges.\n\nStill, anything is better than dying."
	message.show()
func _on_abandon_planet_mouse_exited() -> void:
	message.hide()
