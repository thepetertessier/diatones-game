extends AnimatedSprite2D
class_name BaseAnimatedNote

var frame_secs_elapsed := 0.0
var beat_secs_elapsed := 0.0
var seconds_per_beat := 0.0
var seconds_per_frame := 0.0

const frame_count := 4
const FPS := 8

func update_frame_timing(bpm: float) -> void:
	seconds_per_beat = 60.0 / bpm
	seconds_per_frame = 1.0 / FPS

func reset_timing() -> void:
	frame = 0
	frame_secs_elapsed = 0
	beat_secs_elapsed = 0
	
func _ready() -> void:
	update_frame_timing(100)
	reset_timing()

func _process(delta: float) -> void:
	frame_secs_elapsed += delta
	beat_secs_elapsed += delta
	if frame < frame_count-1:
		if frame_secs_elapsed >= seconds_per_frame:
			frame_secs_elapsed = 0
			frame += 1
	else:
		# We're on the last frame; wait until the next beat
		if beat_secs_elapsed >= seconds_per_beat:
			reset_timing()
