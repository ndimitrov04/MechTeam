extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("intro")
	if not GlobalMusic.initial:
		GlobalMusic.queue_track("res://Audio/Music/11 die vonstantine.ogg", 1.0)
	GlobalMusic.initial = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	IndieBlueprintSceneTransitioner.transition_to(
		SceneCache.SCENES.get("planet_selector"), 
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("CD90B9")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
		}
	)

func _on_play_tutorial_pressed() -> void:
	GlobalMusic.stop()
	IndieBlueprintSceneTransitioner.transition_to(
		preload("res://Scenes/Tutorials/tutorial1.tscn"), 
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("CD90B9")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
		}
	)

func _on_quit_pressed() -> void:
	get_tree().quit()
