extends Control

@onready var menu_panel: Panel = $MenuPanel
@onready var play: Button = $MenuPanel/Play
@onready var options: Button = $MenuPanel/Options
@onready var clear_data: Button = $"MenuPanel/Clear Data"
@onready var quit: Button = $MenuPanel/Quit
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("intro")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mech_builder.tscn")

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
