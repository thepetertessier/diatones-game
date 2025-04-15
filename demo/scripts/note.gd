extends Node2D

@onready var label: Label = $Label
@onready var accidental_label: Label = $AccidentalLabel

func _ready():
	if label == null:
		push_error("Label node not found. Please check the node path.")

func accidental_to_str(accidental) -> String:
	return ['♭♭', '♭', '♮', '♯', '♯♯'][accidental+2]

func set_sprite(duration: int, divisions: int, accidental: int, true_alter: int, stem_is_up: bool) -> void:
	const note_chars = {
		1<<0: "𝅘𝅥𝅲",
		1<<1: "𝅘𝅥𝅱",
		1<<2: "𝅘𝅥𝅰",
		1<<3: "𝅘𝅥𝅯",
		1<<4: "𝅘𝅥𝅮",
		1<<5: "𝅘𝅥",
		1<<6: "𝅗𝅥",
		1<<7: "𝅗"
	}
	var note_char: String = note_chars.get(duration << (6-divisions), '𝅘')
	accidental_label.text = accidental_to_str(true_alter) if accidental != 0 else ''
	label.text = note_char
	label.position = Vector2(-353.173, -1055.878)
	if true_alter < 0:
		accidental_label.position.y = -611.681
	elif true_alter == 0:
		accidental_label.position.y = -491.529
	elif true_alter == 1:
		accidental_label.position.y = -517.016
	else:
		accidental_label.position.y = -375.019
		
	if not stem_is_up:
		label.set_rotation_degrees(180)

func set_rest(type):
	const sub_quarter_y = -604.399
	const half_whole_x = -436.915
	const rest_chars = {
		"64th": ['𝅁', Vector2(-626.245, sub_quarter_y)],
		"32nd": ['𝅀', Vector2(-560.708, sub_quarter_y)],
		"16th": ['𝄿', Vector2(-515.657, sub_quarter_y)],
		"eighth": ['𝄾', Vector2(-407.787, sub_quarter_y)],
		"quarter": ['𝄽', Vector2(-320.404, -855.625)],
		"half": ['𝄼', Vector2(half_whole_x, -717.269)],
		"whole": ['𝄻', Vector2(half_whole_x, -487.888)]
	}
	var char_and_y = rest_chars.get(type, ['', Vector2()])
	label.text = char_and_y[0]
	label.position = char_and_y[1]
	accidental_label.text = ''
