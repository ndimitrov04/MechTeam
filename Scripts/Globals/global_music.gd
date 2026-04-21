extends Node

@onready var track_1: AudioStreamPlayer = $Track1
@onready var track_2: AudioStreamPlayer = $Track2

@onready var initial : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	track_1.volume_db = 0
	track_2.volume_db = -80
	track_1.stream = load("res://Audio/Music/11 die vonstantine.ogg")
	track_1.play()

const MIN_VOLUME : float = -24.0
# Fade out previous track and play new one.
func queue_track(track_path, fade_duration : float) -> void:
	if fade_duration == null:
		fade_duration = 1.0
	
	if track_1.playing:
		track_2.stream = load(track_path)
		track_2.play()
		@warning_ignore("confusable_local_declaration")
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(track_1, "volume_db", MIN_VOLUME, fade_duration)
		tween.parallel().tween_property(track_2, "volume_db", 0.0, fade_duration)
		tween.tween_callback(track_1.stop)
		return
	
	if track_2.playing:
		track_1.stream = load(track_path)
		track_1.play()
		@warning_ignore("confusable_local_declaration")
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(track_2, "volume_db", MIN_VOLUME, fade_duration)
		tween.parallel().tween_property(track_1, "volume_db", 0.0, fade_duration)
		tween.tween_callback(track_2.stop)
		return

	# Fallback if both tracks have stopped
	track_1.stream = load(track_path)
	track_1.play()
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(track_2, "volume_db", MIN_VOLUME, fade_duration)
	tween.parallel().tween_property(track_1, "volume_db", 0.0, fade_duration)
	tween.tween_callback(track_2.stop)

func stop():
	track_1.stop()
	track_2.stop()
