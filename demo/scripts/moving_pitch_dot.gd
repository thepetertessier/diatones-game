extends Node2D

@export var key := 0

const y_top_staff := 0
const y_bottom_staff := 300
const dy := 15 # Divides staff vertically into 20 even parts
const c4 := y_bottom_staff + 4*dy

@onready var pitch_dot: Node2D = $PitchDot

func pos_at_offset(x: float, t: int) -> float:
	# Calculates the y position at a given midi offset
	#assert(t <= x)
	#assert(x <= t+12)
	if x <= t+4:
		return x-t
	if x <= t+5:
		return 2*x - 2*(t+2)
	if x <= t+11:
		return x-t+1
	return 2*x - 2*(t+5)

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
	return midi_to_pos_at_c(midi - 7*key) + 8*key


func _on_pitch_detector__midi_updated(new_midi: float) -> void:
	pitch_dot.position.y = c4 - dy*midi_to_pos(new_midi, key)
