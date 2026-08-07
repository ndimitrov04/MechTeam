extends CanvasLayer

@onready var instruction: Label = $Control/Panel/Instruction
@onready var clip: TextureRect = $Control/Clip1
@onready var clip2: TextureRect = $Control/Clip2

const _0 = preload("uid://cftwij6cytqli")
const _1 = preload("uid://c4w2th36im73b")
const _2 = preload("uid://cmu3cq21nrnrc")
const _3 = preload("uid://yet8hhihxa6b")
const _4 = preload("uid://cvkj3e7s7k1pb")
const _5 = preload("uid://q4ueaui4p88n")
const _6 = preload("uid://cxviw42e01tw7")
const _7 = preload("uid://bajv3m5ygyma7")
const _8 = preload("uid://dun7jn7xeg2gb")
const _9 = preload("uid://druoq6b8u65ak")
const _10 = preload("uid://c4nko5naqou3y")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func load_instruction(inst_string : String):
	instruction.text = inst_string

func load_clip1(number : int):
	match number:
		0:
			clip.texture = _0
		1:
			clip.texture = _1
		2:
			clip.texture = _2
		3:
			clip.texture = _3
		4:
			clip.texture = _4
		5:
			clip.texture = _5
		6:
			clip.texture = _6
		7:
			clip.texture = _7
		8:
			clip.texture = _8
		9:
			clip.texture = _9
		10:
			clip.texture = _10

func load_clip2(number : int):
	match number:
		0:
			clip2.texture = _0
		1:
			clip2.texture = _1
		2:
			clip2.texture = _2
		3:
			clip2.texture = _3
		4:
			clip2.texture = _4
		5:
			clip2.texture = _5
		6:
			clip2.texture = _6
		7:
			clip2.texture = _7
		8:
			clip2.texture = _8
		9:
			clip2.texture = _9
		10:
			clip2.texture = _10
