extends Control

func _on_retry_pressed():
	PlayerData.money -= 30
	IndieBlueprintSceneTransitioner.transition_to(
		get_tree().current_scene.scene_file_path, 
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("55648C")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
		}
	)

func _on_menu_pressed():
	# Reset game variables
	DirAccess.remove_absolute("user://mechteam_save.tres")
	MechData.load_from_file()
	MechData.mechs.clear()
	PlayerData.reset()
	PlayerData.save_run()
	IndieBlueprintSceneTransitioner.transition_to(
		"res://Scenes/menu.tscn", 
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("55648C")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("CD90B9")}
		}
	)

func _on_visibility_changed():
	GlobalMusic.queue_track("uid://c0jwe548hlr0x", 1.0)
