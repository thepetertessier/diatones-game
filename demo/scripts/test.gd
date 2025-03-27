extends Node

func _ready() -> void:
	add_accidental_info('F', 0, 0) # 0
	add_accidental_info('C', 0, 0) # 0
	add_accidental_info('B', 0, 0) # 0
	add_accidental_info('B', -1, 0) # -1
	add_accidental_info('F', -1, 0) # -1
	add_accidental_info('D', 0, -3) # 0
	add_accidental_info('B', 0, -3) # 1
	add_accidental_info('B', 0, -1) # 1
	add_accidental_info('D', 0, 4) # -1
	add_accidental_info('A', -1, 5) # -2

func add_accidental_info(step, alter, key) -> void:
	const fifths = {"F": 0, "C": 1, "G": 2, "D": 3, "A": 4, "E": 5, "B": 6}
	var order = fifths[step]
	print(get_accidental_status(order, alter, key))

func get_accidental_status(order: int, alter: int, key: int) -> int:
	var min_key = order - 6 + 7*alter
	return -floor((key - min_key) / 7.0)
