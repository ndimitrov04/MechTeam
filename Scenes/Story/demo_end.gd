extends Node2D

@onready var panel_1: Node2D = $Panel1
@onready var label_0: Label = $Panel1/Label0
@onready var label_1: Label = $Panel1/Label1
@onready var label_2: Label = $Panel1/Label2
@onready var label_3: Label = $Panel1/Label3

@onready var ui_nodes: Array[CanvasItem] = [
	label_0, label_1, label_2
]


@onready var current_anim = 0
@onready var space_cd: Timer = $SpaceCD
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	credits.show_credits.hide()
	GlobalMusic.stop()
	GlobalMusic.queue_track("res://Audio/Music/3- Ancient prisoner.ogg", 2)
	space_cd.start()
	animation_player.play("FlyIn")

func advance():
	space_cd.start()
	
@onready var credits: Control = $Credits
@onready var label_t: Label = $LabelT
@onready var background: Node2D = $Panel4/Background
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") and space_cd.is_stopped():
		print(current_anim)
		if current_anim == 2:
			animation_player.play("FlyOut")
			label_t.hide()
			var transparent_style := StyleBoxFlat.new()
			transparent_style.bg_color = Color(1, 1, 1, 0)
			credits.credit_panel.add_theme_stylebox_override("panel", transparent_style)
			credits.credit_panel.show()
			credits.show_credits.hide()
			label_3.pop_in()
			scroll_credits()
			credits.crd.text = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" + credits.crd.text + "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
			credits.crd.scroll_active = false
		if current_anim > 0 and current_anim < 3:
			ui_nodes[current_anim].pop_in()
			ui_nodes[current_anim-1].pop_out()
			current_anim += 1
		elif current_anim < 3:
			ui_nodes[current_anim].pop_in()
			current_anim += 1
			
func scroll_credits():
	while true:
		await get_tree().create_timer(0.01).timeout
		credits.crd.get_v_scroll_bar().value += 1.4
