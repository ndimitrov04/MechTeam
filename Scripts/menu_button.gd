extends Button

func _on_pressed() -> void:
	DirAccess.remove_absolute("user://mechteam_save.tres")
	MechData.load_from_file()
	MechData.mechs.clear()
	PlayerData.reset()
	PlayerData.save_run()
	get_parent().get_parent().hide()
	get_tree().paused = false
	IndieBlueprintSceneTransitioner.transition_to(
		SceneCache.SCENES.get("menu"), 
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("55648C")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("CD90B9")}
		}
	)
