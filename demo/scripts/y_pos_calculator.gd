extends Node

var dy: float  # Divides staff vertically into 16 even parts
var c4: float  # Y position of the note C4
var key: int

func set_data(y_top_staff: float, y_bottom_staff: float, note_offset: float, new_key: int) -> void:
	dy = (y_bottom_staff - y_top_staff) / 16.0
	c4 = y_bottom_staff + 4*dy - note_offset*2*dy
	key = new_key

func pre_pos_at_offset(x: float, t: int) -> float:
	#assert(t <= x)
	#assert(x <= t+12)
	if x <= t+4:
		return x-t
	if x <= t+5:
		return 2*x - 2*(t+2)
	if x <= t+11:
		return x-t+1
	return 2*x - 2*(t+5)
	
func pos_at_offset(x: float, t: int) -> float:
	# Calculates the y position at a given midi offset
	return pre_pos_at_offset(x, t) + 7*(t/6-10)

func midi_to_pos_at_c(midi: float) -> float:
	return pos_at_offset(midi, 12*int(midi/12))

func midi_to_pos(midi: float, key: int) -> float:
	# Returns the y position of the note on the staff going up from middle C
	# Return value is scaled based on dy, which splits each space of the staff in 4
	#	i.e., the height of the staff is 5 * 4 * dy
	# midi can be intermediate values
	# If key is 0, represents C Maj. If key is positive, that many sharps are present. If key is negative, that many flats are present
	# e.g., given (midi, key):
	#	(60, 0) => 0.0     # The note C in C Maj
	#	(61, 0) => 1.0     # The note C# in C Maj
	#	(60.5, 0) => 0.5
	#	(72, 0) => 14.0
	#	(64, 0) => 4.0
	#	(64.5, 0) => 5.0
	#	(65, 0) => 6.0
	#	(60, 1) => 0.0     # The note C in G Maj
	#	(64, 1) => 4.0
	#	(65, 1) => 5.0
	#	(66, 1) => 6.0
	#	(66.5, 1) => 7.0
	#	(67, 1) => 8.0
	# As you can see, the result increases at the same rate as midi, except when we're in between two half notes, when it increases twice as fast
	# Visualization: https://www.desmos.com/calculator/vzrew85qnq
	var result = midi_to_pos_at_c(midi - 7*key) + 8*key
	return result

func get_abs_y_pos(midi: float):
	var rel_y = midi_to_pos(midi, key)
	#print("midi = ", midi, "  rel_y = ", rel_y)
	return c4 - dy*rel_y

func get_midi_note(step: String, octave: int, alter: int) -> int:
	# Mapping for basic note values in semitones relative to C.
	var note_values = {
		"C": 0,
		"D": 2,
		"E": 4,
		"F": 5,
		"G": 7,
		"A": 9,
		"B": 11
	}
	
	# Ensure the step is uppercase and valid.
	step = step.to_upper()
	if not note_values.has(step):
		push_error("Invalid note step: " + step)
		return -1
	
	# Compute the MIDI note.
	# MIDI note number formula: (octave + 1) * 12 + note_value + alter.
	# This assumes that middle C (C4) is MIDI note 60.
	var midi_note = (octave + 1) * 12 + note_values[step] + alter
	return midi_note
