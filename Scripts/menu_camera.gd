extends Camera2D

# Shake parameters
@export var intensity: float = 5.0
@export var frequency: float = 10.0
@export var decay: float = 0.95
# Shake may be triggered externally
@export var shake_intensity: float = 0.0

# Internal variables
var noise: FastNoiseLite
var time: float = 0.0

func _ready():
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = frequency

func _process(delta):
	time += delta
   
	# Apply shake
	if shake_intensity > 0.005:
		var offset_x = noise.get_noise_2d(time, 0) * shake_intensity
		var offset_y = noise.get_noise_2d(0, time) * shake_intensity

		# Apply to camera position (relative to parent)
		position = Vector2(offset_x, offset_y)

		# Decay shake intensity
		shake_intensity *= decay
	else:
		# Reset position when shake is minimal
		position = Vector2.ZERO

func shake(magnitude: float = 1.0):
	shake_intensity = magnitude * intensity
