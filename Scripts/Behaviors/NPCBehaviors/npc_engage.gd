extends Node2D

@onready var engage_area = $EngageArea

@onready var disabled : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	engage_area.area_entered.connect(_on_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_area_entered(area):
	if "npc_controllable" in area and not disabled:
		if area.npc_controllable and not area.on_cooldown and area.controlled_module:
			area.npc_engage()
			get_parent().make_busy(5)

func temp_disable(time : float):
	disabled = true
	await get_tree().create_timer(time).timeout
	disabled = false
