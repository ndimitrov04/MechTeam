extends Control

@onready var option_panel: Panel = $OptionPanel

@onready var music_slider: HSlider = $OptionPanel/MusicSlider
@onready var sfx_slider: HSlider = $OptionPanel/SFXSlider
@onready var post_fx: Button = $OptionPanel/PostFX
@onready var fullscreen: CheckButton = $OptionPanel/Fullscreen
@onready var clear_data: Button = $OptionPanel/ClearData
@onready var shaders: CheckButton = $OptionPanel/Shaders

@onready var credit_panel: Panel = $"../Credits/CreditPanel"
@onready var show_credits: Button = $"../Credits/ShowCredits"

const SAVE_PATH = "user://game_options.cfg"
const MUSIC_BUS_NAME = "Music"
const SFX_BUS_NAME = "SFX"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect option signals
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	post_fx.toggled.connect(_on_post_fx_toggled)
	fullscreen.toggled.connect(_on_fullscreen_toggled)
	shaders.toggled.connect(_on_shaders_toggled)
	clear_data.pressed.connect(_show_clear_confirm)
	update_fullscreen_switches()
	if PlayerData.post_fx_enabled:
		post_fx.set_pressed_no_signal(true)
	else:
		post_fx.set_pressed_no_signal(false)
	if PlayerData.shaders_enabled:
		shaders.set_pressed_no_signal(true)
	else:
		shaders.set_pressed_no_signal(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if PlayerData.post_fx_enabled:
		post_fx.set_pressed_no_signal(true)
	else:
		post_fx.set_pressed_no_signal(false)
	if PlayerData.shaders_enabled:
		shaders.set_pressed_no_signal(true)
	else:
		shaders.set_pressed_no_signal(false)


func update_fullscreen_switches():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullscreen.set_pressed_no_signal(true)
	else:
		fullscreen.set_pressed_no_signal(false)

func _on_show_options_toggled(toggled_on: bool) -> void:
	if toggled_on:
		option_panel.show()
		credit_panel.hide()
		show_credits.button_pressed = false
	else:
		option_panel.hide()

func _on_music_volume_changed(value):
	var bus_idx = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	AudioServer.set_bus_volume_db(bus_idx, music_slider.value)

func _on_sfx_volume_changed(value):
	var bus_idx = AudioServer.get_bus_index(SFX_BUS_NAME)
	AudioServer.set_bus_volume_db(bus_idx, sfx_slider.value)

func _on_post_fx_toggled(is_enabled):
	if is_enabled:
		PlayerData.post_fx_enabled = true
	else:
		PlayerData.post_fx_enabled = false

func _on_shaders_toggled(is_enabled):
	if is_enabled:
		PlayerData.shaders_enabled = true
	else:
		PlayerData.shaders_enabled = false

func _on_fullscreen_toggled(is_enabled):
	if is_enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		@warning_ignore("integer_division")
		DisplayServer.window_set_size(Vector2i(1920/2, 1080/2))
	update_fullscreen_switches()

func _show_clear_confirm():
	DirAccess.remove_absolute("user://mechteam_save.tres")
	MechData.load_from_file()
	MechData.mechs.clear()
	PlayerData.reset()
	PlayerData.save_run()
	print("Game data cleared.")

func _clear_game_data():
	pass
