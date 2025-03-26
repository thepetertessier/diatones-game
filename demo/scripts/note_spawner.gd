extends Node2D

# Exported variables for configuration.
@export var note_scene: PackedScene  # The scene to instantiate for each note.
@export var spawn_x := 3000.0

@onready var timer: Timer = $Timer
@onready var y_pos_calculator: Node = %YPosCalculator

var tick_duration: float
var divisions: int
var notes_per_tick := {}
var current_tick := 0
var note_index := 0
var next_note: Dictionary
var next_tick := 0
var ticks_and_notes: Array = []
var seconds_per_beat: float
var travel_time: float
var ticks_on_screen: int
var finished := false

func set_data(song_info) -> void:
	var BPM = song_info["bpm"]
	divisions = song_info["divisions"]
	seconds_per_beat = 60.0 / BPM
	tick_duration = seconds_per_beat / divisions
	timer.set_wait_time(tick_duration)
	set_ticks_and_notes(song_info)
	next_tick = ticks_and_notes[0][0]
	next_note = ticks_and_notes[0][1]
	const beats_on_screen := 12
	ticks_on_screen = beats_on_screen*divisions
	travel_time = beats_on_screen * seconds_per_beat
	spawn_preliminary_notes()

func spawn_preliminary_notes():
	while spawn_next_note_if_ready():
		pass
	
func alter_to_str(alter):
	return ['♭', '♮', '♯'][alter+1]
	
func note_to_str(note_data):
	if note_data.is_rest:
		return "rest"
	var note_pitch = note_data["pitch"]
	return note_pitch["step"] + alter_to_str(note_pitch["alter"]) + str(note_pitch["octave"])

func set_ticks_and_notes(song_info: Dictionary) -> void:
	var tick := 0
	for note in song_info["notes"]:
		ticks_and_notes.append([tick, note])
		print("Added note " + note_to_str(note) + " at tick " + str(tick))
		tick += note["duration"]

# This function spawns one note at a time.
func spawn_note(note_data, ticks_away=ticks_on_screen) -> void:
	#TODO: implement rest
	if note_data["is_rest"]:
		return
	
	var note_instance = note_scene.instantiate()
	note_instance.position.x = spawn_x * float(ticks_away) / ticks_on_screen
	var pitch_data = note_data["pitch"]
	var step = pitch_data["step"]
	var octave = pitch_data["octave"]
	var alter = pitch_data["alter"]
	var midi = y_pos_calculator.get_midi_note(step, octave, alter)
	var y_pos = y_pos_calculator.get_abs_y_pos(midi)
	const y_adjust := -20
	note_instance.position.y = y_pos + y_adjust
	add_child(note_instance)
	
	# Animate the note to move toward the target vertical line.
	animate_note(note_instance, ticks_away)

# Animate the note instance so that it reaches the target at the right time.
func animate_note(note_instance: Node2D, ticks_away: int) -> void:
	# Compute the target position. In this case, we only change the x coordinate.
	var target_position = note_instance.position
	target_position.x = 0
	
	# Create a Tween to animate the note's position.
	var tween = get_tree().create_tween()
	var adjusted_travel_time = travel_time * float(ticks_away) / ticks_on_screen
	tween.tween_property(note_instance, "position", target_position, adjusted_travel_time)
	tween.tween_callback(note_instance.queue_free)
	
func spawn_next_note_if_ready() -> bool:
	# Returns true/false whether we spawned a note
	if finished:
		return false
	var ticks_away = next_tick - current_tick
	if ticks_away <= ticks_on_screen:
		spawn_note(next_note, ticks_away)
		note_index += 1
		if note_index >= ticks_and_notes.size():
			finished = true
			return true
		var next_tick_and_note = ticks_and_notes[note_index]
		next_tick = next_tick_and_note[0]
		next_note = next_tick_and_note[1]
		return true
	return false

func _on_conductor_beat_hit(beats_passed: float) -> void:
	# Sync ticks and timer
	current_tick = beats_passed*divisions
	timer.start()
	print("tick: ", current_tick, "---")
	spawn_next_note_if_ready()

func _on_timer_timeout() -> void:
	# Runs every tick, for when there's notes in between beats
	current_tick += 1
	print("tick: ", current_tick)
	spawn_next_note_if_ready()
