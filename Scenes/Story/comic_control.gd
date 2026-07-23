extends Node2D

@onready var panel_1: Node2D = $Panel1
@onready var label_0: Label = $Panel1/Label0

@onready var panel_2: Node2D = $Panel2
@onready var part_1: Node2D = $Panel2/Part1
@onready var label_1: Label = $Panel2/Part1/Label1
@onready var part_2: Node2D = $Panel2/Part2
@onready var label_2: Label = $Panel2/Part2/Label2
@onready var part_3: Node2D = $Panel2/Part3
@onready var label_3: Label = $Panel2/Part3/Label3

@onready var panel_3: Node2D = $Panel3
@onready var label_4: Label = $Panel3/Label4
@onready var label_5: Label = $Panel3/Label5

@onready var panel_4: Node2D = $Panel4
@onready var part_4: Node2D = $Panel4/Part4
@onready var label_6: Label = $Panel4/Part4/Label6

@onready var panel_5: Node2D = $Panel5
@onready var part_5: Node2D = $Panel5/Part5
@onready var _3: AnimatedSprite2D = $"Panel5/Part5/3"
@onready var _2: AnimatedSprite2D = $"Panel5/Part5/2"
@onready var _1: AnimatedSprite2D = $"Panel5/Part5/1"
@onready var mc: AnimatedSprite2D = $Panel5/Part5/MC
@onready var label_7: Label = $Panel5/Part5/Label1

@onready var part_6: Node2D = $Panel5/Part6
@onready var label_8: Label = $Panel5/Part6/Label2

@onready var ui_nodes: Array[CanvasItem] = [
	panel_1,
	label_0,

	panel_2,
	part_1,
	label_1,
	part_2,
	label_2,
	part_3,
	label_3,

	panel_3,
	label_4,
	label_5,

	panel_4,
	part_4,
	label_6,

	panel_5,
	part_5,
	mc,
	_1,
	_2,
	_3,
	label_7,

	part_6,
	label_8,
]


@onready var current_anim = 0
@onready var space_cd: Timer = $SpaceCD

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalMusic.stop()
	space_cd.start()

func advance():
	space_cd.start()
	ui_nodes[current_anim].pop_in()
	current_anim += 1
	
@onready var background: Node2D = $Panel4/Background
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") and space_cd.is_stopped():
		print(current_anim)
		match current_anim:
			0:
				GlobalMusic.queue_track("res://Audio/Music/13 the end.ogg", 2)
				advance()
				advance()
			2:
				for i in range(3):
					await get_tree().create_timer(0.3).timeout
					advance()
			5:
				for i in range(2):
					await get_tree().create_timer(0.3).timeout
					advance()
			7:
				for i in range(2):
					await get_tree().create_timer(0.3).timeout
					advance()
			9:
				for i in range(2):
					await get_tree().create_timer(0.3).timeout
					advance()
			12:
				for i in range(3):
					background.started = true
					await get_tree().create_timer(0.3).timeout
					advance()
			15:
				for i in range(9):
					await get_tree().create_timer(0.3).timeout
					advance()
			24:
				IndieBlueprintSceneTransitioner.transition_to(
					SceneCache.SCENES.get("opening"), 
					IndieBlueprintPremadeTransitions.Dissolve,
					IndieBlueprintPremadeTransitions.Dissolve,
					{ 
						"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("CD90B9")},
						"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
					}
				)
			_:
				if current_anim < 24:
					advance()
