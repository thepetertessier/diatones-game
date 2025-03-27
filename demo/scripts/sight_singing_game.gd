extends Control

@export_file("*.xml") var music_xml: String = "res://assets/musicxml/Locriana's Lament.xml"
@export var music_mp3: AudioStreamMP3

@onready var staff_game: Node2D = $StaffGame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	staff_game.set_song_and_start(music_xml, music_mp3)
