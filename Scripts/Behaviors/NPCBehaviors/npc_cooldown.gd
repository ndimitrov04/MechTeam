extends Node2D

@onready var timer = $Timer
@onready var cooldown_bar = $CooldownBar

@onready var cooldown_time : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.timeout.connect(_end)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var time_elapsed = cooldown_time - timer.time_left
	var time_percentage_left = time_elapsed / cooldown_time * cooldown_bar.max_value
	cooldown_bar.value = cooldown_bar.max_value - time_percentage_left

func start(time : float):
	cooldown_time = time
	timer.start(cooldown_time)

func _end():
	pass
	# Do nothing, all elements
	# are self contained for now.
