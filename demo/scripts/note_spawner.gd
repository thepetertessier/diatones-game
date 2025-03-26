extends Node2D

# Exported variables for configuration.
@export var note_scene: PackedScene  # The scene to instantiate for each note.
@export var spawn_x := 2000.0

@onready var song_generator: Node = $SongGenerator

# Array of note dictionaries from your intermediate representation.
var notes_data: Array = []
var current_note_index: int = 0

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
		#animate_note(note_instance, note_data)
		
		current_note_index += 1
		
		# Schedule the next note spawn at the next beat.
		# You could adjust this timing based on note duration or other timing info.
		#await get_tree().create_timer(beat_interval)
		spawn_next_note()

# Animate the note instance so that it reaches the target at the right time.
#func animate_note(note_instance: Node2D, note_data: Dictionary) -> void:
	## Here, note_data.duration is assumed to be in divisions (or quarter notes if normalized)
	## so we compute travel_time in seconds. For example, if duration=1 means one beat:
	#var travel_time: float = note_data.get("duration", 1) * beat_interval
	#
	## Compute the target position. In this case, we only change the x coordinate.
	#var target_position = note_instance.position
	#target_position.x = target_x
	#
	## Create a Tween to animate the note's position.
	#var tween = Tween.new()
	#note_instance.add_child(tween)
	#tween.tween_property(note_instance, "position", target_position, travel_time)
	#tween.play()
