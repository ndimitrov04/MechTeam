extends Node2D

@onready var mech = $"../../.."

@onready var disabled : bool = false

@onready var repair_timer: Timer = $RepairTimer
@onready var repair_sfx: AudioStreamPlayer2D = $RepairSFX

# Called when the node enters the scene tree for the first time.
func _ready():
	repair_timer.timeout.connect(_on_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_timeout():
	if mech.hp + 5 < mech.max_hp and not disabled:
		get_parent().make_busy(7)
		repair_sfx.play()
		for i in range(5):
			await get_tree().create_timer(0.7).timeout
			get_parent().get_parent().get_parent().hp += 2

func temp_disable(time : float):
	disabled = true
	await get_tree().create_timer(time).timeout
	disabled = false
