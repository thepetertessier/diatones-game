@tool
extends Node2D

@export var beats: int = 4 :
	get:
		return beats
	set(value):
		beats = value
		update_display()

@export var beat_type: int = 4 :
	get:
		return beat_type
	set(value):
		beat_type = value
		update_display()


func _ready() -> void:
	update_display()

func update_display():
	var beats_label = get_node_or_null("BeatsLabel")
	var beat_type_label = get_node_or_null("BeatTypeLabel")
	if beats_label:
		beats_label.text = str(beats)
	if beat_type_label:
		beat_type_label.text = str(beat_type)
	print("Updated time signature: ", beats, "/", beat_type)
