extends Control

@onready var music = $"../../../Music"

func _on_retry_pressed():
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/mech_builder.tscn")

func _on_visibility_changed():
	music.stream = preload("uid://c0jwe548hlr0x")
	music.play()
