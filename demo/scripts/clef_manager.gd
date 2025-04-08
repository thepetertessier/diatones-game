@tool
extends Node2D

enum {TREBLE, TENOR, BASS}

var note_offset := 0

@export_enum("Treble", "Tenor", "Bass") var clef: int = 0 :
	get:
		return clef
	set(value):
		clef = value
		update_display()

func _ready() -> void:
	update_display()

func update_display():
	var clef_label = get_node_or_null("ClefLabel")
	if not clef_label:
		return
	
	position.y = 0
	%KeyManager.position.y = 0
	
	match clef:
		TREBLE:
			clef_label.text = '𝄞'
			note_offset = 0
		TENOR:
			clef_label.text = '𝄠'
			note_offset = 7
		BASS:
			clef_label.text = '𝄢'
			position.y = -35
			note_offset = 12
			%KeyManager.position.y = 75
			
	#print("Updated clef: ", clef)
