extends SubViewportContainer

@onready var main: Node2D = $"../../../../.."
@onready var sub_viewport = $SubViewport
@onready var action_panel: Panel = $".."
@onready var action_camera: Camera2D = $SubViewport/ActionCamera
@onready var action_timeout: Timer = $"../ActionTimeout"
@onready var damage_label: Label = $"../DamageDealt"

const ACTION_TIME : float = 1.5
const TIMEOUT_TIME : float = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	action_panel.hide()
	action_camera.custom_viewport = sub_viewport
	sub_viewport.world_2d = get_viewport().world_2d

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func show_action(target_position : Vector2, damage_dealt : int = 0):
	PlayerData.damage_combo += damage_dealt
	damage_label.text = "Damage Dealt: " + str(PlayerData.damage_combo)
	if target_position.distance_to(main.player.global_position) < (960 / main.player.zoom.x):
		return
	if action_timeout.time_left < ACTION_TIME or action_timeout.is_stopped():
		action_timeout.start(TIMEOUT_TIME)
		action_camera.position = target_position
		action_panel.show()
	
func _on_action_timeout_timeout() -> void:
	action_panel.hide()
	PlayerData.damage_combo = 0
