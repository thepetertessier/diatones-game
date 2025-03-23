extends Node2D

@onready var staff_line: Line2D = $HorizontalLines/StaffLine
@onready var staff_line_5: Line2D = $HorizontalLines/StaffLine5

func get_top_staff_y() -> float:
	return staff_line.position.y

func get_bottom_staff_y() -> float:
	return staff_line_5.position.y
	
