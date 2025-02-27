extends PitchDetector

signal _pitch_updated(pitch: float)

var pitch: float = 0

var capture: AudioEffectCapture
var spectrum_analyzer: AudioEffectSpectrumAnalyzerInstance

const buffer_size: int = 2048  # Must match C++ script
const sample_rate: int = 44100
const min_frequency = 50
const max_frequency = 1000

func _ready():
	const CAPTURE_EFFECT_IDX = 1
	const SPECTRUM_EFFECT_IDX = 2
	
	# Ensure the bus name matches the one set in the Audio Bus Layout
	var mic_bus_index = AudioServer.get_bus_index("Microphone");
	capture = AudioServer.get_bus_effect(mic_bus_index, CAPTURE_EFFECT_IDX) as AudioEffectCapture
	spectrum_analyzer = AudioServer.get_bus_effect_instance(mic_bus_index, SPECTRUM_EFFECT_IDX) as AudioEffectSpectrumAnalyzerInstance

func _process(_delta):
	if capture and capture.can_get_buffer(buffer_size):  # Adjust buffer size as needed
		var audio_buffer = capture.get_buffer(buffer_size)
		pitch = get_pitch(audio_buffer)
		emit_signal("_pitch_updated", pitch)
		
		# Get system stats
		var cpu_usage = Performance.get_monitor(Performance.TIME_PROCESS) * 100  # CPU usage in %
		var fps = Performance.get_monitor(Performance.TIME_FPS)  # Framerate

		# Print the stats
		print("Pitch: %.2f Hz | CPU: %.2f%% | FPS: %d" % [pitch, cpu_usage, fps])
		
func get_pitch(audio_buffer):
	#return detect_pitch(audio_buffer, sample_rate, min_frequency, max_frequency)
	return detect_pitch_from_spectrum_analyzer()
	
# Convert a MIDI note number to its frequency (in Hz).
func midi_to_freq(midi: int) -> float:
	return 440.0 * pow(2.0, (midi - 69) / 12.0)

# Convert a MIDI note number to a note name string (e.g., "A4").
func midi_to_note_name(midi: int) -> String:
	var note_names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	var octave = (midi / 12) - 1
	var note = note_names[midi % 12]
	return "%s%d" % [note, octave]

# detect_pitch() returns the note name (as a String) for which the magnitude is highest.
func detect_pitch_from_spectrum_analyzer() -> float:
	if spectrum_analyzer == null:
		return 0.0
	
	var best_note = ""
	var best_magnitude = -1.0
	var best_freq = -1.0
	
	# Loop over candidate MIDI notes from E2 (midi 40) to B5 (midi 83)
	for midi in range(40, 84):
		var freq = midi_to_freq(midi)
		# Define a window that is half a semitone wide on either side
		var lower_bound = freq / pow(2.0, 1.0 / 24.0)
		var upper_bound = freq * pow(2.0, 1.0 / 24.0)
		# Get the magnitude vector for this frequency range
		var magnitude = spectrum_analyzer.get_magnitude_for_frequency_range(lower_bound, upper_bound).length()
		
		# Update the best candidate if this band is louder
		if magnitude > best_magnitude:
			best_magnitude = magnitude
			best_note = midi_to_note_name(midi)
			best_freq = freq
	
	print("Detected note: " + best_note)
	return best_freq
