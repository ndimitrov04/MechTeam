extends CanvasLayer

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
