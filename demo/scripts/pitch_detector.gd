extends PitchDetector

signal _pitch_updated(new_pitch: float)

var pitch: float = 0

var capture: AudioEffectCapture
var spectrum_analyzer: AudioEffectSpectrumAnalyzerInstance

const buffer_size: int = 2048  # Must match C++ script
const sample_rate: int = 44100
const min_frequency = 50
const max_frequency = 500

func _ready():
	const CAPTURE_EFFECT_IDX = 1
	
	# Ensure the bus name matches the one set in the Audio Bus Layout
	var mic_bus_index = AudioServer.get_bus_index("Microphone");
	capture = AudioServer.get_bus_effect(mic_bus_index, CAPTURE_EFFECT_IDX) as AudioEffectCapture

func _process(_delta):
	if capture and capture.can_get_buffer(buffer_size):  # Adjust buffer size as needed
		var audio_buffer = capture.get_buffer(buffer_size)
		pitch = get_pitch(audio_buffer)
		emit_signal("_pitch_updated", pitch)

func get_pitch(audio_buffer):
	return detect_pitch(audio_buffer, sample_rate, min_frequency, max_frequency)
	#return detect_pitch_from_spectrum_analyzer()
