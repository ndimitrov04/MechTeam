extends AnimatedSprite2D

@onready var floor_detector: ShapeCast2D = $FloorDetector
@onready var dust: GPUParticles2D = $Dust
@onready var start_dust: AnimatedSprite2D = $Dust/StartDust

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
