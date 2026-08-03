extends Control

@onready var mech = $"../../../Mech"
@onready var player = $"../../../Player"

@onready var player_hp: AnimatedSprite2D = $StatusPanel/PlayerHP
@onready var hp_bar: TextureProgressBar = $StatusPanel/HPBar
@onready var en_bar: TextureProgressBar = $StatusPanel/ENBar
@onready var hp_label = $StatusPanel/HPLabel
@onready var en_label = $StatusPanel/ENLabel
@onready var status = $StatusPanel/Status

@onready var camera_panel = $CameraPanel
@onready var initial_camera_panel_position = camera_panel.position
@onready var status_timeout = $StatusPanel/Status/StatusTimeout

@onready var minigame_result = $MinigameResult
@onready var advance = $Advance

@onready var lose: AudioStreamPlayer = $"../SFX/Lose"
@onready var win: AudioStreamPlayer = $"../SFX/Win"

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.1).timeout
	status_timeout.timeout.connect(_on_status_timeout)
	if has_meta("bars"):
		hp_bar.max_value = mech.max_hp
		en_bar.max_value = mech.energy

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if has_meta("bars"):
		if player.hp <= 5:
			player_hp.frame = player.hp
		hp_label.text = "HP " + str(int(mech.hp))
		hp_bar.value = mech.hp
		en_label.text = "EN " + str(int(mech.energy))
		en_bar.value = mech.energy
	else:
		hp_label.text = "Player Health: " + str(int(player.hp)) + "\nMech Health: " + str(int(mech.hp))
		en_label.text = "Energy: " + str(mech.energy)

func _unhandled_input(event):
	if event.is_action_pressed("show_cameras"):
		if camera_panel.position.y <= initial_camera_panel_position.y:
			# Slide panel off screen (down)
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_SINE)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(camera_panel, "position:y", initial_camera_panel_position.y + camera_panel.size.y, 1)
		else:
			# Slide panel from off screen (up) to initial position
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_SINE)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(camera_panel, "position:y", initial_camera_panel_position.y, 1)

func set_status(message : String):
	status.text = "Status\n" + message
	status_timeout.start()

func clear_status():
	status.text = "Status\n"

func _on_status_timeout():
	clear_status()

# Loss reason: 0 - Regular fail; 1 - Knocked off of controller
func display_minigame_result(victory : bool, loss_reason = 0):
	if victory:
		minigame_result.text = "Engaging Module!"
		minigame_result.add_theme_color_override("font_color", Color("green"))
		win.play()
	else:
		if loss_reason == 0:
			minigame_result.text = "Insufficient Energy!"
		elif loss_reason == 1:
			minigame_result.text = "Failure! Couldn't hold on!"
		minigame_result.add_theme_color_override("font_color", Color("red"))
		lose.play()
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

func display_advance_arrow():
	advance.show()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	# Flash sequence
	tween.tween_property(advance, "modulate:a", 0.0, 0.1)
	tween.tween_property(advance, "modulate:a", 1.0, 0.3)
	tween.tween_property(advance, "modulate:a", 1.0, 0.1)
	tween.tween_property(advance, "modulate:a", 0.0, 0.1)
	tween.tween_property(advance, "modulate:a", 1.0, 0.3)
	tween.tween_property(advance, "modulate:a", 1.0, 0.1)
	tween.tween_property(advance, "modulate:a", 0.0, 0.1)
	tween.tween_property(advance, "modulate:a", 1.0, 0.3)
	tween.tween_property(advance, "modulate:a", 1.0, 0.1)
	tween.tween_property(advance, "modulate:a", 0.0, 0.1)
	tween.tween_property(advance, "modulate:a", 1.0, 0.3)
	tween.tween_property(advance, "modulate:a", 1.0, 0.1)
	# Fade out after 0.6 sec
	tween.tween_property(advance, "modulate:a", 0, 0.1)
