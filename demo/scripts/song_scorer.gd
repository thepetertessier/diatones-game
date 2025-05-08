class_name SongScorer
extends Node

@export var currently_detecting_voice := false  # Set from StaffGame

var cumulative_score := 0.0
var note_count := 0
var current_target_midi := 0
var current_db := 0.0
const MIDI_REST := -999

@onready var y_pos_calculator: Node = %YPosCalculator

func set_data(song_info: Dictionary):
	pass

# Computes cents difference between two MIDI note numbers
func cents_diff(midi1: float, midi2: float) -> float:
	return (midi1 - midi2) * 100.0

# Given cents error, map to [0,1] with linear fall-off
func score_from_cents_error(cents_error: float, max_error := 50.0) -> float:
	var e = abs(cents_error)
	return 0.0 if e >= max_error else 1.0 - (e / max_error)

# Inside whatever function you use to process each sung note:
func get_note_score(detected_midi: float, target_midi: int) -> float:
	var error_in_cents = cents_diff(detected_midi, target_midi)
	return score_from_cents_error(error_in_cents)
	
func get_midi_from_pitch_data(pitch_data: Dictionary) -> float:
	return y_pos_calculator.get_midi_note(
		pitch_data["step"],
		pitch_data["octave"],
		pitch_data["alter"]
	)

func score_note(detected_midi: float) -> void:
	var note_score = get_note_score(detected_midi, current_target_midi)
	cumulative_score += note_score
	note_count += 1
	show_score_feedback(note_score)

func show_score_feedback(note_score: float):
	print("Note score: ", note_score)

func _on_note_spawner_note_hit(note_data: Dictionary) -> void:
	current_target_midi = MIDI_REST if note_data.is_rest else get_midi_from_pitch_data(note_data["pitch"])
