extends PitchDetector

var capture: AudioEffectCapture
const buffer_size: int = 1024

func _ready():
	# Ensure the bus name matches the one set in the Audio Bus Layout
	var mic_bus_index = AudioServer.get_bus_index("Microphone");
	capture = AudioServer.get_bus_effect(mic_bus_index, 0) as AudioEffectCapture

func _process(_delta):
	if capture and capture.can_get_buffer(buffer_size):  # Adjust buffer size as needed
		var audio_buffer = capture.get_buffer(buffer_size)
		var pitch = detect_pitch(audio_buffer, buffer_size)
		print("Detected Frequency: ", pitch)
		
		# Get system stats
		var cpu_usage = Performance.get_monitor(Performance.TIME_PROCESS) * 100  # CPU usage in %
		var fps = Performance.get_monitor(Performance.TIME_FPS)  # Framerate

		# Print the stats
		print("Pitch: %.2f Hz | CPU: %.2f%% | FPS: %d" % [pitch, cpu_usage, fps])
