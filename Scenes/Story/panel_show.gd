extends CanvasItem

@export var fade_duration: float = 0.3

var _tween: Tween

func _ready() -> void:
	visible = false
	modulate.a = 0.0

func pop_in() -> void:
	if _tween and _tween.is_running():
		_tween.kill()

	visible = true
	modulate.a = 0.0

	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, fade_duration)

func pop_out() -> void:
	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	_tween.tween_callback(func():
		visible = false
	)

func print_o():
	print(name)
