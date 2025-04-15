extends Node2D

@onready var timer: Timer = $Timer
@onready var y_pos_calculator: Node = %YPosCalculator
@onready var key_manager: Node2D = %KeyManager

var spawn_x := 3000.0
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
var note_scene: PackedScene
var measure_bar_scene: PackedScene
var beats: int

func set_data(song_info) -> void:
	var BPM = song_info["bpm"]
	spawn_x = max(3000, 40*(BPM - 5))  # Musical notes move faster when BPM is higher
	divisions = song_info["divisions"]
	beats = song_info["time_signature"]["beats"]
	seconds_per_beat = 60.0 / BPM
	tick_duration = seconds_per_beat / divisions
	timer.set_wait_time(tick_duration)
	set_ticks_and_notes(song_info)
	next_tick = ticks_and_notes[0][0]
	next_note = ticks_and_notes[0][1]
	const beats_on_screen := 12
	ticks_on_screen = beats_on_screen*divisions
	travel_time = beats_on_screen * seconds_per_beat
	note_scene = preload("res://scenes/note.tscn")
	measure_bar_scene = preload("res://scenes/vertical_staff_line.tscn")

func start():
	spawn_all_ready_notes()
	
func alter_to_str(alter):
	return ['♭', '♮', '♯'][alter+1]
	
func note_to_str(note_data):
	if note_data.is_rest:
		return "rest"
	var note_pitch = note_data["pitch"]
	return note_pitch["step"] + alter_to_str(note_pitch["alter"]) + str(note_pitch["octave"])

func add_accidental_info(note_data: Dictionary, key: int) -> void:
	var alter = note_data["pitch"]["alter"]
	var step = note_data["pitch"]["step"]
	const fifths = {"F": 0, "C": 1, "G": 2, "D": 3, "A": 4, "E": 5, "B": 6}
	var order = fifths[step]
	note_data["accidental"] = get_accidental_status(order, alter, key)

func get_accidental_status(order: int, alter: int, key: int) -> int:
	var min_key = order - 6 + 7*alter
	return -floor((key - min_key) / 7.0)

func set_ticks_and_notes(song_info: Dictionary) -> void:
	var tick := 0
	for note in song_info["notes"]:
		if not note["duration"]:
			continue
		if not note["is_rest"]:
			add_accidental_info(note, key_manager.key)
		ticks_and_notes.append([tick, note])
		#print("Added note " + note_to_str(note) + " at tick " + str(tick))
		tick += note["duration"]
		
func get_adjusted_spawn_x(ticks_away):
	return spawn_x * float(ticks_away) / ticks_on_screen

# This function spawns one note at a time.
func spawn_note(note_data, ticks_away=ticks_on_screen) -> void:
	var note_instance = note_scene.instantiate()
	add_child(note_instance)
	var y_pos = 150
	
	if note_data["is_rest"]:
		note_instance.set_rest(note_data["type"])
	else:
		var pitch_data = note_data["pitch"]
		var step = pitch_data["step"]
		var octave = pitch_data["octave"]
		var alter = pitch_data["alter"]
		var midi = y_pos_calculator.get_midi_note(step, octave, alter)
		midi -= note_data["accidental"]  # Adjust for accidental; e.g., if it's flat, it is displayed a little higher
		y_pos = y_pos_calculator.get_abs_y_pos(midi)
		note_instance.set_sprite(note_data["duration"], divisions, note_data["accidental"], alter, note_data["stem_is_up"])
		
	const y_adjust := 20
	note_instance.position.y = y_pos + y_adjust
	
	# Animate the note to move toward the target vertical line.
	animate_note(note_instance, ticks_away)

# Animate the note instance so that it reaches the target at the right time.
func animate_note(note_instance: Node2D, ticks_away: int, x_adjust := 0.0) -> void:
	# Compute the target position. In this case, we only change the x coordinate.
	note_instance.position.x += get_adjusted_spawn_x(ticks_away) + x_adjust
	var target_position = note_instance.position
	target_position.x = 60  # Experimentally determined
	target_position.x += x_adjust
	
	# Create a Tween to animate the note's position.
	var tween = get_tree().create_tween()
	var adjusted_travel_time = travel_time * float(ticks_away) / ticks_on_screen
	tween.tween_property(note_instance, "position", target_position, adjusted_travel_time)
	tween.tween_property(note_instance, "scale", Vector2(), tick_duration)
	tween.parallel().tween_property(note_instance, "position", Vector2(target_position.x-50, target_position.y), tick_duration)
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
		
		# Spawn measure bar if ready
		if next_tick % (divisions * beats) == 0:
			spawn_measure_bar(next_tick - current_tick)
		
		return true
	return false

func spawn_measure_bar(ticks_away):
	var measure_bar = measure_bar_scene.instantiate()
	add_child(measure_bar)
	animate_note(measure_bar, ticks_away, -100)
	
func spawn_all_ready_notes():
	while spawn_next_note_if_ready():
		pass

func _on_conductor_beat_hit(beats_passed: float) -> void:
	# Sync ticks and timer
	current_tick = beats_passed*divisions
	timer.start()
	#print("tick: ", current_tick, "---")
	spawn_all_ready_notes()

func _on_timer_timeout() -> void:
	# Runs every tick, for when there's notes in between beats
	current_tick += 1
	#print("tick: ", current_tick)
	spawn_all_ready_notes()
