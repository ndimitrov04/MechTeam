extends Control

func _on_retry_pressed():
	get_tree().reload_current_scene()

func _on_menu_pressed():
	# Reset game variables
	DirAccess.remove_absolute("user://mechteam_save.tres")
	MechData.load_from_file()
	MechData.mechs.clear()
	print("Game data cleared.")
	PlayerData.reset()
	get_tree().change_scene_to_file("res://Scenes/mech_builder.tscn")

func _on_visibility_changed():
	GlobalMusic.queue_track("uid://c0jwe548hlr0x", 1.0)
