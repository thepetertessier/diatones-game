# Responsible for emitting the beat_hit signal
extends Node

signal beat_hit(beats_passed: float)

@onready var music_player: AudioStreamPlayer = %MusicPlayer

@export var BPM := 80
var seconds_per_beat := 60.0 / BPM

var time_begin
var time_delay

var beats_passed := 0
var next_timestamp := 0.0

func _ready():
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	
func start():
	time_begin = Time.get_ticks_usec()
	music_player.play()

func get_time():
	# Obtain from ticks.
	var time = (Time.get_ticks_usec() - time_begin) / 1000000.0
	# Compensate for latency.
	time -= time_delay
	# May be below 0 (did not begin yet).
	time = max(0, time)
	return time
	
func _process(_delta: float) -> void:
	if not time_begin:
		return
	if get_time() >= next_timestamp:
		beat_hit.emit(beats_passed)
		#print("Beat: ", beats_passed)
		beats_passed += 1
		next_timestamp = seconds_per_beat*beats_passed
