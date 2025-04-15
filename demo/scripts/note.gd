extends Node2D

@onready var label: Label = $Label
@onready var accidental_label: Label = $AccidentalLabel

func _ready():
	if label == null:
		push_error("Label node not found. Please check the node path.")

func accidental_to_str(accidental) -> String:
	return ['♭♭', '♭', '♮', '♯', '♯♯'][accidental+2]

func set_sprite(duration: int, divisions: int, accidental: int, true_alter: int) -> void:
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
	if true_alter < 0:
		accidental_label.position.y = -611.681
	elif true_alter == 0:
		accidental_label.position.y = -491.529
	elif true_alter == 1:
		accidental_label.position.y = -517.016
	else:
		accidental_label.position.y = -375.019
