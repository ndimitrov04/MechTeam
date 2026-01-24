extends Control

@onready var timer = $Timer
@onready var timebar = $Timebar

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.timeout.connect(_on_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var time_elapsed = timer.wait_time - timer.time_left
	var time_percentage_left = time_elapsed / timer.wait_time * timebar.max_value
	timebar.value = timebar.max_value - time_percentage_left

func start(time : float):
	timer.start(time)

func _on_timeout():
	get_parent().lose()
