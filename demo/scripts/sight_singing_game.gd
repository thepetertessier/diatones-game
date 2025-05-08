@tool
extends Control

@export_file("*.xml") var music_xml: String = "res://assets/musicxml/Locriana's Lament.xml"
@export var music_mp3: AudioStreamMP3
@export var song_title: String = "Locriana's Lament" :
	set(value):
		song_title = value
		$TitleLabel.text = song_title

@onready var staff_game: Node2D = $StaffGame
@onready var start_button: Button = $StartButton

func _ready() -> void:
	if not Engine.is_editor_hint():
		staff_game.set_song(music_xml, music_mp3)
	
func _on_start_button_pressed() -> void:
	start_button.visible = false
	staff_game.start()
