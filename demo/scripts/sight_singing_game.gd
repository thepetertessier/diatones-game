extends Control

@export_file("*.xml") var music_xml: String = "res://assets/musicxml/Locriana's Lament.xml"
@export var music_mp3: AudioStreamMP3

@onready var staff_game: Node2D = $StaffGame
@onready var start_button: Button = $StartButton
	
func _on_start_button_pressed() -> void:
	start_button.visible = false
	staff_game.set_song_and_start(music_xml, music_mp3)
