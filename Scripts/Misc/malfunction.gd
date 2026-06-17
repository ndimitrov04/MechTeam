extends Area2D

@onready var main = $"../../.."

@onready var interaction_label: Label = $InteractionLabel
@onready var malfunction_timer: Timer = $MalfunctionTimer
@onready var malfunction_sprite: Sprite2D = $MalfunctionSprite

@onready var player_in_range: bool = false
@onready var timeout_time: float = 10
@onready var damage: float = 15

@onready var appear_sfx: AudioStreamPlayer2D = $SFX/Appear
@onready var fix_sfx: AudioStreamPlayer2D = $SFX/Fix
@onready var critical_sfx: AudioStreamPlayer2D = $SFX/Critical
@onready var malfunction_explosion: AudioStreamPlayer2D = $SFX/MalfunctionExplosion

@onready var red_fade
@onready var blinking: bool = true

# Placeholders to comply with npc_engage behaviour scene
@onready var npc_controllable: bool = true
@onready var on_cooldown: bool = false
@onready var controlled_module: bool = true

const DEBRIS = preload("uid://rg2m11gs0xex")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	malfunction_timer.timeout.connect(_malfunction_critical)
	
	red_fade = create_tween()
	red_fade.tween_property(self, "modulate", Color(1,0.5,0,1), 10.0)
	
	appear_sfx.play()
	
	malfunction_timer.start(timeout_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not blinking:
		malfunction_sprite.visible = true
	else:
		malfunction_sprite.visible = Time.get_ticks_msec() % 1000 < 500

func _unhandled_input(event):
	if player_in_range:
		if event.is_action_pressed("interact"):
			fix()

func _on_body_entered(body):
	if body.name == "Player":
		interaction_label.visible = true
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		interaction_label.visible = false
		player_in_range = false

func _malfunction_critical():
	interaction_label.show()
	interaction_label.text = "MALFUNCTION CRITICAL!"
	if red_fade:
		red_fade.kill()
	blinking = false
	malfunction_sprite.modulate = Color.RED
	malfunction_sprite.visible = true
	# Spawn debris
	var debris_instance
	debris_instance = DEBRIS.instantiate()
	main.add_child(debris_instance)
	debris_instance.global_position = global_position
	get_parent().get_parent().take_damage(damage)
	critical_sfx.play()
	malfunction_explosion.play()
	await get_tree().create_timer(1).timeout
	queue_free()

func fix():
	interaction_label.show()
	interaction_label.text = "Malfunction Fixed :)"
	interaction_label.label_settings.font_color = Color.GREEN
	if red_fade:
		red_fade.kill()
	blinking = false
	malfunction_sprite.modulate = Color.GREEN
	malfunction_sprite.visible = true
	get_parent().get_parent().hp += damage / 3
	fix_sfx.play()
	await get_tree().create_timer(1).timeout
	queue_free()

func npc_engage():
	fix()
