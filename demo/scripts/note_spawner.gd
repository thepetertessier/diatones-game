extends Node2D

# Exported variables for configuration.
@export var note_scene: PackedScene  # The scene to instantiate for each note.
@export var spawn_x := 2000.0

@onready var timer: Timer = $Timer

signal finished_setting_up

# Array of note dictionaries from your intermediate representation.
var notes_data: Array = []
var current_note_index: int = 0

var tick_duration: float
var divisions: int
var notes_per_tick := {}
var current_tick := 0
var note_index := 0
var next_note := "rest"
var next_tick := 0
var ticks_and_notes: Array = []

func set_data(song_info) -> void:
	var BPM = song_info["bpm"]
	divisions = song_info["divisions"]
	set_tick_duration(divisions, BPM)
	timer.set_wait_time(tick_duration)
	set_ticks_and_notes(song_info)
	next_tick = ticks_and_notes[0][0]
	next_note = ticks_and_notes[0][1]
	finished_setting_up.emit()

func set_tick_duration(divisions: int, BPM: float) -> void:
	var seconds_per_beat = 60.0 / BPM
	tick_duration = seconds_per_beat / divisions
	
func alter_to_str(alter):
	return ['♭', '♮', '♯'][alter+1]
	
func set_ticks_and_notes(song_info: Dictionary) -> void:
	var tick := 0
	for note in song_info["notes"]:
		var note_str
		if note.is_rest:
			note_str = "rest"
		else:
			var note_pitch = note["pitch"]
			note_str = note_pitch["step"] + alter_to_str(note_pitch["alter"]) + str(note_pitch["octave"])
		ticks_and_notes.append([tick, note_str])
		print("Added note " + note_str + " at tick " + str(tick))
		tick += note["duration"]

# Call this function with your intermediate representation (e.g., after parsing MusicXML).
func start_spawning(intermediate_rep: Dictionary) -> void:
	# Assumes intermediate_rep.notes is an array of note data.
	notes_data = intermediate_rep["notes"]
	current_note_index = 0
	spawn_next_note()

# This function spawns one note at a time.
func spawn_next_note() -> void:
	if current_note_index < notes_data.size():
		var note_data = notes_data[current_note_index]
		var note_instance = note_scene.instantiate()
		note_instance.position.x = spawn_x
		add_child(note_instance)
		
		# Animate the note to move toward the target vertical line.
		animate_note(note_instance, note_data)
		
		current_note_index += 1


# Animate the note instance so that it reaches the target at the right time.
func animate_note(note_instance: Node2D, note_data: Dictionary) -> void:
	# Here, note_data.duration is assumed to be in divisions (or quarter notes if normalized)
	# so we compute travel_time in seconds. For example, if duration=1 means one beat:
	#var travel_time: float = note_data.get("duration", 1) * beat_interval
	#
	## Compute the target position. In this case, we only change the x coordinate.
	#var target_position = note_instance.position
	#target_position.x = target_x
	
	# Create a Tween to animate the note's position.
	var tween = Tween.new()
	note_instance.add_child(tween)
	#tween.tween_property(note_instance, "position", target_position, travel_time)
	tween.play()
	
func spawn_next_note_if_ready() -> void:
	if next_tick <= current_tick:
		# Placeholder
		print("Note now: ", next_note)
		note_index += 1
		var next_tick_and_note = ticks_and_notes[note_index]
		next_tick = next_tick_and_note[0]
		next_note = next_tick_and_note[1]

func _on_conductor_beat_hit(beats_passed: float) -> void:
	# Sync ticks and timer
	current_tick = beats_passed*divisions
	timer.start()
	print("tick: ", current_tick, "---")
	spawn_next_note_if_ready()

func _on_timer_timeout() -> void:
	# Runs every tick
	current_tick += 1
	print("tick: ", current_tick)
	spawn_next_note_if_ready()
