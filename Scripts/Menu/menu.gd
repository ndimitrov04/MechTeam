extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var player: CharacterBody2D = $Player

@onready var continue_run: Button = $Menu/MenuPanel/ContinueRun

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("intro")
	if not GlobalMusic.initial:
		GlobalMusic.queue_track("res://Audio/Music/11 die vonstantine.ogg", 1.0)
	GlobalMusic.initial = false
	PlayerData.load_run()
	if PlayerData.current_stage == 1:
		continue_run.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	PlayerData.reset()
	if (PlayerData.current_stage - 1) % 3 == 0:
		IndieBlueprintSceneTransitioner.transition_to(
			SceneCache.SCENES.get("planet_selector"), 
			IndieBlueprintPremadeTransitions.Dissolve,
			IndieBlueprintPremadeTransitions.Dissolve,
			{ 
				"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("CD90B9")},
				"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
			}
		)
	else:
		IndieBlueprintSceneTransitioner.transition_to(
			SceneCache.SCENES.get("mech_builder"), 
			IndieBlueprintPremadeTransitions.Dissolve,
			IndieBlueprintPremadeTransitions.Dissolve,
			{ 
				"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("CD90B9")},
				"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
			}
		)


func _on_continue_run_pressed() -> void:

	if (PlayerData.current_stage - 1) % 3 == 0:
		IndieBlueprintSceneTransitioner.transition_to(
			SceneCache.SCENES.get("planet_selector"), 
			IndieBlueprintPremadeTransitions.Dissolve,
			IndieBlueprintPremadeTransitions.Dissolve,
			{ 
				"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("CD90B9")},
				"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
			}
		)
	else:
		IndieBlueprintSceneTransitioner.transition_to(
			SceneCache.SCENES.get("mech_builder"), 
			IndieBlueprintPremadeTransitions.Dissolve,
			IndieBlueprintPremadeTransitions.Dissolve,
			{ 
				"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("CD90B9")},
				"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
			}
		)

func _on_play_tutorial_pressed() -> void:
	PlayerData.reset()
	GlobalMusic.stop()
	IndieBlueprintSceneTransitioner.transition_to(
		SceneCache.SCENES.get("comic_1"), 
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("CD90B9")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
		}
	)

func _on_quit_pressed() -> void:
	get_tree().quit()
