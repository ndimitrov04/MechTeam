extends ColorRect

@export var blink_duration: float = 0.5    # Time for one fade cycle (in seconds)
@export var max_opacity: float = 1.0       # Opacity when fully visible
@export var min_opacity: float = 0.0       # Opacity when fully invisible

var tween: Tween

func _ready():
	start_blinking()

func start_blinking():
	if tween:
		tween.kill() # Stop any existing animation

	tween = create_tween().set_loops() # Create a new tween that loops infinitely

	# 1. Fade OUT to min_opacity
	tween.tween_property(self, "modulate:a", min_opacity, blink_duration)

	# 2. Fade IN back to max_opacity
	# We chain the next action using .follow() so it starts immediately after the first finishes
	tween.tween_property(self, "modulate:a", max_opacity, blink_duration)

# Optional: Call this from another script to stop/start
func stop_blinking():
	if tween:
		tween.kill()
