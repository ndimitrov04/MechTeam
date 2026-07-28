extends Node2D

@onready var panel_1: Node2D = $Panel1
@onready var label_0: Label = $Panel1/Label0
@onready var label_1: Label = $Panel1/Label1
@onready var label_2: Label = $Panel1/Label2
@onready var label_3: Label = $Panel1/Label3
@onready var label_4: Label = $Panel1/Label4
@onready var label_5: Label = $Panel1/Label5
@onready var label_6: Label = $Panel1/Label6

@onready var ui_nodes: Array[CanvasItem] = [
	label_0,
	label_1,
	label_2,
	label_3,
	label_4,
	label_5,
	label_6
]


@onready var current_anim = 0
@onready var space_cd: Timer = $SpaceCD
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalMusic.stop()
	GlobalMusic.queue_track("res://Audio/Music/S31-Night Prowler.ogg", 2)
	space_cd.start()
	animation_player.play("FlyIn")

func advance():
	space_cd.start()
	
@onready var background: Node2D = $Panel4/Background
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") and space_cd.is_stopped():
		print(current_anim)
		if current_anim == 7:
			IndieBlueprintSceneTransitioner.transition_to(
				SceneCache.SCENES.get("planet_selector"), 
				IndieBlueprintPremadeTransitions.Dissolve,
				IndieBlueprintPremadeTransitions.Dissolve,
				{ 
					"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("CD90B9")},
					"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
				}
			)
		elif current_anim > 0:
			ui_nodes[current_anim].pop_in()
			ui_nodes[current_anim-1].pop_out()
			current_anim += 1
		else:
			ui_nodes[current_anim].pop_in()
			current_anim += 1
