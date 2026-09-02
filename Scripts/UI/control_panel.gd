extends Panel

@onready var mech

@onready var buttons: Control = $Buttons
@onready var brake: Button = $Buttons/Brake
@onready var jump: Button = $Buttons/Jump
@onready var left: Button = $Buttons/Left
@onready var right: Button = $Buttons/Right

@onready var confirm: AudioStreamPlayer = $SFX/Confirm
@onready var deny: AudioStreamPlayer = $SFX/Deny

@onready var rc_status: Label = $RCStatus

const ONLINE = "ONLINE"
const OFFLINE = "OFFLINE"
enum DIRECTION {LEFT = -1, BRAKE = 0, RIGHT = 1, JUMP = 2}

@onready var pilots_available

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	mech = get_parent().mech
	left.pressed.connect(_go_left)
	right.pressed.connect(_go_right)
	jump.pressed.connect(_jump)
	brake.pressed.connect(_brake)
	pilots_available = mech.pilots

func queue_command(direction):
	for NPC in mech.npcs.get_children():
		if not NPC.has_meta("is_pilot"):
			continue
		if not NPC.npc_cooldown.timer.is_stopped():
			continue
		NPC.make_busy(10)
		if direction == 2:
			mech.jump = true
		else:
			mech.direction = direction
		get_parent().set_status("Pilot executing command!")
		confirm.play()
		pilots_available -= 1
		if pilots_available <= 0:
			disable_controls()
		await get_tree().create_timer(10).timeout
		pilots_available += 1
		if pilots_available > 0:
			enable_controls()
		return
	get_parent().set_status("CANNOT EXECUTE!\nNO PILOTS AVAILABLE!")
	deny.play()

func _go_left():
	queue_command(DIRECTION.LEFT)

func _go_right():
	queue_command(DIRECTION.RIGHT)

func _jump():
	queue_command(DIRECTION.JUMP)

func _brake():
	queue_command(DIRECTION.BRAKE)

func disable_controls():
	#for button in buttons.get_children():
		#button.disabled = true
	rc_status.text = OFFLINE
	rc_status.add_theme_color_override("font_color", Color.RED)

func enable_controls():
	#for button in buttons.get_children():
		#button.disabled = false
	rc_status.text = ONLINE
	rc_status.add_theme_color_override("font_color", Color.GREEN)
