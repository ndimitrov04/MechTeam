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
	get_tree().change_scene_to_file("res://Scenes/planet_selector.tscn")

func _on_play_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Tutorials/tutorial1.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
