extends Node

enum {TREBLE, TENOR, BASS}

func _ready() -> void:
	print(get_ledger_lines(TREBLE, "C", 6))  # High C6: returns 2
	print(get_ledger_lines(BASS, "E", 1))    # Low E1: returns 4
	print(get_ledger_lines(BASS, "F", 2))    # 0
	print(get_ledger_lines(BASS, "E", 2))    # 1
	print(get_ledger_lines(BASS, "D", 2))    # 1
	print(get_ledger_lines(BASS, "C", 2))    # 2
	print(get_ledger_lines(BASS, "B", 1))    # 2
	print(get_ledger_lines(TREBLE, "G", 4))  # G4 (second line): returns 0


func get_ledger_lines(clef: int, note_step: String, octave: int) -> int:
	# Define the reference line note and octave for each clef
	var clef_reference = {
		TREBLE: {"note": "E", "octave": 4, "staff_position": 0},  # bottom line is E4
		TENOR: {"note": "E", "octave": 3, "staff_position": 0},   # bottom line is E3
		BASS: {"note": "G", "octave": 2, "staff_position": 0},    # bottom line is G2
	}

	# Map note steps to numbers (C=0, D=1, ..., B=6)
	var note_to_number = {"C": 0, "D": 1, "E": 2, "F": 3, "G": 4, "A": 5, "B": 6}

	# Calculate the total staff step difference from the clef's reference
	var ref = clef_reference[clef]
	var ref_step = note_to_number[ref["note"]]
	var input_step = note_to_number[note_step]
	var total_steps = (octave - ref["octave"]) * 7 + (input_step - ref_step)

	# In standard 5-line staves, the lines go from position 0 (bottom line) to position 8 (top line)
	# Positions -1 and 9 are the spaces just outside the staff; ledger lines start beyond that.
	var staff_range = 8
	var staff_half_range = staff_range / 2

	# Determine how many positions off the staff the note is
	var absolute_pos = ref["staff_position"] + total_steps

	if absolute_pos >= 0 and absolute_pos <= staff_range:
		return 0  # within the staff
	elif absolute_pos < 0:
		return int((-absolute_pos) / 2)
	else:
		return int((absolute_pos - staff_range) / 2)
