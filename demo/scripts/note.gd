extends Node2D

@onready var label: Label = $Label
@onready var accidental_label: Label = $AccidentalLabel

func _ready():
	if label == null:
		push_error("Label node not found. Please check the node path.")

func accidental_to_str(accidental) -> String:
	return ['♭', '', '♯'][accidental+1]

func set_sprite(duration: int, divisions: int, accidental: int) -> void:
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
	accidental_label.text = accidental_to_str(accidental)
	label.text = note_char
	if accidental < 0:
		accidental_label.position.y = -611.681
	if accidental > 0:
		accidental_label.position.y = -517.016
