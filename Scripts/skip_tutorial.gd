extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func _on_pressed() -> void:
	# Clear game data from tutorial
	PlayerData.reset()
	DirAccess.remove_absolute("user://mechteam_save.tres")
	MechData.load_from_file()
	MechData.mechs.clear()
	PlayerData.money += 25
	print("Game data cleared.")
	await get_tree().create_timer(0.1).timeout
	IndieBlueprintSceneTransitioner.transition_to(
		SceneCache.SCENES.get("comic_2"),
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("55648C")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
		}
	)
