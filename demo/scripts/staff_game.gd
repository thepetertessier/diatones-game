extends Node2D

@export_file("*.xml") var music_xml: String = "res://assets/musicxml/Locriana's Lament.xml"

@onready var song_generator: Node = $SongGenerator
@onready var staff: Node2D = $Staff
@onready var pitch_dot: Node2D = $PitchHitX/PitchDot
@onready var key_manager: Node2D = $KeyManager
@onready var time_signature_manager: Node2D = %TimeSignatureManager
@onready var clef_manager: Node2D = $ClefManager
@onready var y_pos_calculator: Node = $YPosCalculator
@onready var conductor: Node = %Conductor
@onready var note_spawner: Node2D = %NoteSpawner

func _ready() -> void:
	var song_info = song_generator.parse_musicxml(music_xml)
	
	key_manager.key = song_info["key"]
	time_signature_manager.beats = song_info["time_signature"]["beats"]
	time_signature_manager.beat_type = song_info["time_signature"]["beat_type"]
	clef_manager.clef = song_info["clef"]
	for element in [key_manager, time_signature_manager, clef_manager]:
		element.update_display()
	
	y_pos_calculator.set_data(staff.get_top_staff_y(), staff.get_bottom_staff_y(), clef_manager.note_offset, key_manager.key)
	note_spawner.set_data(song_info)
	#note_spawner.start_spawning(song_info)
	await note_spawner.finished_setting_up
	conductor.start()

func set_pitch_dot_y(midi: float):
	var new_y = y_pos_calculator.get_abs_y_pos(midi)
	pitch_dot.position.y = new_y

func _on_pitch_detector_midi_updated(new_midi: float) -> void:
	set_pitch_dot_y(new_midi)
