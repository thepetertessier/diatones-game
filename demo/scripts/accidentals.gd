@tool
extends Node2D

const FLAT = preload("res://assets/images/flat.svg")
const SHARP = preload("res://assets/images/sharp.svg")
const x_start := 300

@onready var staff: Node2D = %Staff
@onready var staff_game: Node2D = $".."

@onready var y_top_staff: float = staff.get_top_staff_y()
@onready var y_bottom_staff: float  = staff.get_bottom_staff_y()
@onready var dy: float = (y_bottom_staff - y_top_staff) / 16.0  # Divides staff vertically into 16 even parts
@onready var c4: float = y_bottom_staff + 4*dy  # Y position of the note C4

@export var key: int = 0 :
	get:
		return key
	set(value):
		key = value
		if staff_game:
			staff_game.set_key(value)
		update_display()  # A custom function that updates the display based on the key

func _ready() -> void:
	update_display()

func update_display():
	var flats = []
	var sharps = []
	for i in range(1,8):
		var flat_node = get_node_or_null("Flats/Flat" + str(i))
		if flat_node:
			flat_node.visible = false
			flats.append(flat_node)

		var sharp_node = get_node_or_null("Sharps/Sharp" + str(i))
		if sharp_node:
			sharp_node.visible = false
			sharps.append(sharp_node)

	# Ensure the loop doesn't try to access a missing index
	for i in range(key, 0):
		if -i-1 < len(flats):
			var flat = flats[-i-1]
			flat.visible = true
	for i in range(0, key):
		if i < len(sharps):
			var sharp = sharps[i]
			sharp.visible = true
	
	var time_signature_manager = get_node_or_null("%TimeSignatureManager")
	if time_signature_manager:
		time_signature_manager.position.x = 300 + abs(key)*60
	
	print("Updated key to ", key)
