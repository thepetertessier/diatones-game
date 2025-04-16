extends Node2D

@onready var label: Label = $Label
@onready var accidental_label: Label = $AccidentalLabel
@onready var ledgers: Node2D = $Label/Ledgers
@onready var ledger_line_1: Node2D = $Label/Ledgers/LedgerLine1
@onready var ledger_line_2: Node2D = $Label/Ledgers/LedgerLine2
@onready var inline: Line2D = $Label/Ledgers/LedgerLine2/Inline
@onready var in_label: Label = $Label/Ledgers/LedgerLine1/InLabel

func _ready():
	if label == null:
		push_error("Label node not found. Please check the node path.")
	ledger_line_1.set_visible(false)
	ledger_line_2.set_visible(false)

func accidental_to_str(accidental) -> String:
	return ['𝄫', '♭', '♮', '♯', '𝄪'][accidental+2]

func set_sprite(type: String, accidental: int, true_alter: int, stem_is_up: bool, ledger: int) -> void:
	const note_chars = {
		"64th": "𝅘𝅥𝅱",
		"32nd": "𝅘𝅥𝅰",
		"16th": "𝅘𝅥𝅯",
		"eighth": "𝅘𝅥𝅮",
		"quarter": "𝅘𝅥",
		"half": "𝅗𝅥",
		"whole": "𝅗"
	}
	var note_char: String = note_chars.get(type, '𝅘')
	if note_char in ['𝅗', '𝅘']:
		# Otherwise it would make it look like it has a tiny staff
		inline.set_visible(false)
	
	if note_char in ['𝅗𝅥', '𝅗']:
		in_label.text = '𝅗'
	else:
		in_label.text = '𝅘'
	
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
	
	if ledger >= 2:
		ledger_line_1.set_visible(true)
	if ledger >= 4:
		ledger_line_2.set_visible(true)
	
	#if ledger % 2 == 1:
		#ledgers.position.y -= 100

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
