extends Node

var capture: AudioEffectCapture
const buffer_size: int = 1024

func _ready():
	# Ensure the bus name matches the one set in the Audio Bus Layout
	var mic_bus_index = AudioServer.get_bus_index("Microphone");
	capture = AudioServer.get_bus_effect(mic_bus_index, 0) as AudioEffectCapture

func _process(_delta):
	if capture and capture.can_get_buffer(buffer_size):  # Adjust buffer size as needed
		var audio_buffer = capture.get_buffer(buffer_size)
		process_audio(audio_buffer)

func process_audio(audio_buffer: PackedVector2Array):
	# Example: Print first few samples for debugging
	print(audio_buffer.slice(0, 10))
