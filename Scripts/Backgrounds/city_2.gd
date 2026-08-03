extends Node2D

@onready var rain_far: GPUParticles2D = $Parallax/Parallax2/RainFar
@onready var rain_near: GPUParticles2D = $Parallax/Parallax7/RainNear
@onready var rain: GPUParticles2D = $Parallax/Parallax3/Rain

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if PlayerData.post_fx_enabled:
		rain_far.emitting = true
		rain_near.emitting = true
		rain.emitting = true
	else:
		rain_far.emitting = false
		rain_near.emitting = false
		rain.emitting = false
