extends Control

@onready var mech = $"../../../Mech"

@onready var hp_label = $HPLabel
@onready var en_label = $ENLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	hp_label.text = "Health: " + str(mech.hp)
	en_label.text = "Energy: " + str(mech.energy)
