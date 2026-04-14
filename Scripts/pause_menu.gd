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
	get_tree().reload_current_scene()

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
	get_tree().change_scene_to_file("res://Scenes/planet_selector.tscn")

func _on_visibility_changed() -> void:
	if get_tree().current_scene.name == "Editor":
		retry.hide()
		abandon_planet.show()
	elif get_tree().current_scene.name == "Main":
		retry.show()
		abandon_planet.show()
	elif get_tree().current_scene.name == "PlanetSelector":
		retry.hide()
		abandon_planet.hide()
