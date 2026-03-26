extends Node2D

@onready var navigation: NavigationAgent2D = $Navigation
@onready var retarget: Timer = $Retarget
@onready var controlled_object = $".."

@onready var target_player : bool = false
@onready var moving : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	_retarget()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if moving:
		#The velocity the enemy is going to move in (towards the target)
		controlled_object.velocity = global_position.direction_to(navigation.get_next_path_position()) * controlled_object.SPEED
	else:
		controlled_object.velocity = Vector2(0,0)

func stop_moving(time : float):
	moving = false
	await get_tree().create_timer(time).timeout
	moving = true

func _retarget():
	if target_player:
		navigation.target_position = get_tree().current_scene.player.global_position
		return
	# Target mech at random point
	var mech_position = get_tree().current_scene.mech.global_position
	navigation.target_position = mech_position + Vector2(randf_range(0, 930), randf_range(0, 420))
