extends Node

const EMPTY_CELL = Vector2i(-1,-1)
@onready var grid_size : Vector2i = Vector2i(34, 17)

@onready var blocks : Array
@onready var walls : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(0, grid_size.x):
		blocks.append([])
		for y in range(0, grid_size.y):
			blocks.back().append(EMPTY_CELL)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
