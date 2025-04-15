extends Node2D

@export_file("*.xml") var music_xml: String = "res://assets/musicxml/Locriana's Lament.xml"
@export var music_mp3: AudioStreamMP3

@onready var song_generator: Node = $SongGenerator
@onready var staff: Node2D = $Staff
@onready var key_manager: Node2D = $KeyManager
@onready var time_signature_manager: Node2D = %TimeSignatureManager
@onready var clef_manager: Node2D = $ClefManager
@onready var y_pos_calculator: Node = $YPosCalculator
@onready var conductor: Node = %Conductor
@onready var music_player: AudioStreamPlayer = %MusicPlayer
@onready var note_spawner: Node2D = %NoteSpawner
@onready var pitch_detector: PitchDetector = %PitchDetector
@onready var pitch_dot: Node2D = %PitchDot

var bpm: float

func set_song(new_music_xml: String, new_music_mp3: AudioStreamMP3) -> void:
	music_xml = new_music_xml
	music_mp3 = new_music_mp3

	var song_info = song_generator.parse_musicxml(music_xml)
	
	key_manager.key = song_info["key"]
	time_signature_manager.beats = song_info["time_signature"]["beats"]
	time_signature_manager.beat_type = song_info["time_signature"]["beat_type"]
	clef_manager.clef = song_info["clef"]
	for element in [key_manager, time_signature_manager, clef_manager]:
		element.update_display()
	
	y_pos_calculator.set_data(staff.get_top_staff_y(), staff.get_bottom_staff_y(), clef_manager.note_offset, key_manager.key)
	note_spawner.set_data(song_info)
	music_player.stream = music_mp3
	bpm = song_info["bpm"]

func start():
	note_spawner.start()
	conductor.start(bpm)

func set_pitch_dot_y(midi: float):
	var new_y = y_pos_calculator.get_abs_y_pos(midi)
	pitch_dot.position.y = new_y

func _on_pitch_detector_midi_updated(new_midi: float) -> void:
	set_pitch_dot_y(new_midi)
	
func db_to_percentage(db: float) -> float:
	var min_db := -60.0  # Set a noise floor (ignore anything quieter than this)
	db = clamp(db, min_db, 0.0)
	
	# Remap range [-30 to -3] into [0.0 to 1.0] with an exponential curve
	var normalized := (db + 30.0) / 27.0  # Maps -30 -> 0, -3 -> 1
	var curved := pow(normalized, 4.0)    # Smooth curve — adjust exponent for shape
	return clamp(curved, 0.0, 1.0)

func _on_pitch_detector_db_updated(new_db: float) -> void:
	#print("Db: ", new_db)
	pitch_dot.set_particle_amount(db_to_percentage(new_db))
