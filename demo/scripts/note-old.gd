extends AnimatedSprite2D

const frame_count := 4
const FPS := 8
const seconds_per_frame := 1.0 / FPS

var frame_secs_elapsed := 0.0
var seconds_per_beat := 0.0
var beat_finished := false	

func reset_timing() -> void:
	frame = 0
	frame_secs_elapsed = 0
	
func _ready() -> void:
	reset_timing()

func _process(delta: float) -> void:
	frame_secs_elapsed += delta
	if frame < frame_count-1:
		if frame_secs_elapsed >= seconds_per_frame:
			frame_secs_elapsed = 0
			frame += 1
	else:
		# We're on the last frame; wait until the next beat
		# Must be more accurate than simply delta
		if beat_finished:
			reset_timing()
			beat_finished = false

func on_beat_hit():
	beat_finished = true
