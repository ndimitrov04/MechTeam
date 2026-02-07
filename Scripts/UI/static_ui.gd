extends Control

@onready var mech = $"../../../Mech"

@onready var hp_label = $StatusPanel/HPLabel
@onready var en_label = $StatusPanel/ENLabel
@onready var status = $StatusPanel/Status

@onready var camera_panel = $CameraPanel
@onready var initial_camera_panel_position = camera_panel.position
@onready var status_timeout = $StatusPanel/Status/StatusTimeout

@onready var minigame_result = $MinigameResult

# Called when the node enters the scene tree for the first time.
func _ready():
	status_timeout.timeout.connect(_on_status_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	hp_label.text = "Health: " + str(mech.hp)
	en_label.text = "Energy: " + str(mech.energy)

func _unhandled_input(event):
	if event.is_action_pressed("show_cameras"):
		if camera_panel.position.y <= initial_camera_panel_position.y:
			# Slide panel off screen (down)
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_BACK)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(camera_panel, "position:y", initial_camera_panel_position.y + camera_panel.size.y, 1)
		else:
			# Slide panel from off screen (up) to initial position
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_BACK)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(camera_panel, "position:y", initial_camera_panel_position.y, 1)

func set_status(message : String):
	status.text = "Status\n" + message
	status_timeout.start()

func clear_status():
	status.text = "Status\n"

func _on_status_timeout():
	clear_status()

func display_minigame_result(victory : bool):
	if victory:
		minigame_result.text = "Minigame Success!!!"
		minigame_result.add_theme_color_override("font_color", Color("green"))
	else:
		minigame_result.text = "Minigame Failure..."
		minigame_result.add_theme_color_override("font_color", Color("red"))
	minigame_result.modulate = Color(1, 1, 1, 1)  # Make visible
	minigame_result.show()
	# Flash effect - 4 quick flashes over 0.4 seconds, then keep visible for 0.6 seconds
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	# Flash sequence
	tween.tween_property(minigame_result, "modulate:a", 0.0, 0.1)
	tween.tween_property(minigame_result, "modulate:a", 1.0, 0.1)
	tween.tween_property(minigame_result, "modulate:a", 0.0, 0.1)
	tween.tween_property(minigame_result, "modulate:a", 1.0, 0.1)
	# Keep visible for 0.6 sec
	tween.tween_property(minigame_result, "modulate:a", 1.0, 0.6)
	# Fade out after 0.6 sec
	tween.tween_property(minigame_result, "modulate:a", 0, 0.6)
