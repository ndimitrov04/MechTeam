extends Control

@onready var option_panel: Panel = $OptionPanel

@onready var music_slider: HSlider = $OptionPanel/MusicSlider
@onready var sfx_slider: HSlider = $OptionPanel/SFXSlider
@onready var fullscreen: Button = $OptionPanel/Fullscreen
@onready var clear_data: Button = $OptionPanel/ClearData

const SAVE_PATH = "user://game_options.cfg"
const MUSIC_BUS_NAME = "Music"
const SFX_BUS_NAME = "SFX"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect option signals
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	fullscreen.toggled.connect(_on_fullscreen_toggled)
	clear_data.pressed.connect(_show_clear_confirm)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_show_options_toggled(toggled_on: bool) -> void:
	if toggled_on:
		option_panel.show()
	else:
		option_panel.hide()

func _on_music_volume_changed(value):
	var bus_idx = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	AudioServer.set_bus_volume_db(bus_idx, music_slider.value)

func _on_sfx_volume_changed(value):
	var bus_idx = AudioServer.get_bus_index(SFX_BUS_NAME)
	AudioServer.set_bus_volume_db(bus_idx, sfx_slider.value)

func _on_fullscreen_toggled(is_enabled):
	if is_enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1920/2, 1080/2))

func _show_clear_confirm():
	DirAccess.remove_absolute("user://mechteam_save.tres")
	MechData.load_from_file()
	MechData.mechs.clear()
	print("Game data cleared.")

func _clear_game_data():
	pass
