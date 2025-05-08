@tool
extends Node2D

func get_top_staff_y() -> float:
	return $HorizontalLines/StaffLine.position.y

func get_bottom_staff_y() -> float:
	return $HorizontalLines/StaffLine5.position.y
