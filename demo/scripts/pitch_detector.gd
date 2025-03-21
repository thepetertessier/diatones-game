extends PitchDetector
# Responsible for emitting the midi detected from microphone

#signal _pitch_updated(new_pitch: float)
signal _midi_updated(new_midi: float)

var capture: AudioEffectCapture
var spectrum_analyzer: AudioEffectSpectrumAnalyzerInstance

const buffer_size: int = 2048  # Must match C++ script
const sample_rate: int = 44100
const min_frequency = 50
const max_frequency = 1000

func _ready():
	const CAPTURE_EFFECT_IDX = 1
	
	# Ensure the bus name matches the one set in the Audio Bus Layout
	var mic_bus_index = AudioServer.get_bus_index("Microphone");
	capture = AudioServer.get_bus_effect(mic_bus_index, CAPTURE_EFFECT_IDX) as AudioEffectCapture

func get_midi(audio_buffer):
	return detect_midi(audio_buffer, sample_rate, min_frequency, max_frequency)

func _on_timer_timeout() -> void:
	# Runs at 10 FPS to save computational load
	if capture and capture.can_get_buffer(buffer_size):  # Adjust buffer size as needed
		var audio_buffer = capture.get_buffer(buffer_size)
		var midi: float = get_midi(audio_buffer)
		midi += 1.3 # Manual adjustment
		emit_signal("_midi_updated", midi)
