extends Node2D

@onready var staff: Node2D = $Staff
@onready var pitch_dot: Node2D = $PitchHitX/PitchDot
@onready var key_manager: Node2D = $KeyManager
@onready var clef_manager: Node2D = $ClefManager

@onready var key: int = key_manager.key

@onready var y_top_staff: float = staff.get_top_staff_y()
@onready var y_bottom_staff: float  = staff.get_bottom_staff_y()
@onready var dy: float = (y_bottom_staff - y_top_staff) / 16.0  # Divides staff vertically into 16 even parts
var c4: float  # Y position of the note C4

func _ready() -> void:
	set_c4(clef_manager.note_offset)

func set_key(new_key):
	key = new_key
	
func set_c4(new_note_offset):
	c4 = y_bottom_staff + 4*dy - new_note_offset*2*dy

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
	print("midi = ", midi, "  rel_y = ", rel_y)
	return c4 - dy*rel_y

func set_pitch_dot_y(midi: float):
	var new_y = get_abs_y_pos(midi)
	pitch_dot.position.y = new_y
	#print("abs_y = ", new_y)

func _on_pitch_detector_midi_updated(new_midi: float) -> void:
	set_pitch_dot_y(new_midi)
