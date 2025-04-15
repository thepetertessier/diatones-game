extends PitchDetector
# Responsible for emitting the midi detected from microphone

signal midi_updated(new_midi: float)

var thread: Thread

const buffer_size: int = 2048
const sample_rate: int = 44100
const min_frequency = 50
const max_frequency = 1000
const msec_delay := 100

var thread_should_stop := false

# Shared variable for pitch, protected by a Mutex
var latest_midi: float = -999
var pitch_mutex := Mutex.new()
var latest_midi_main: float = -999

func _ready():
	# Set up thread
	thread = Thread.new()
	thread.start(thread_function)

func get_midi(audio_buffer):
	return detect_midi(audio_buffer, sample_rate, min_frequency, max_frequency)

func get_midi_from_microphone(capture) -> float:
	if capture and capture.can_get_buffer(buffer_size):
		var audio_buffer = capture.get_buffer(buffer_size)
		var midi: float = get_midi(audio_buffer)
		midi += 1.3 # Manual adjustment
		return midi
	return -999

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	thread_should_stop = true
	thread.wait_to_finish()

func thread_function():
	const CAPTURE_EFFECT_IDX = 1
	var mic_bus_index = AudioServer.get_bus_index("Microphone")
	var capture = AudioServer.get_bus_effect(mic_bus_index, CAPTURE_EFFECT_IDX) as AudioEffectCapture
	
	while not thread_should_stop:
		var midi = get_midi_from_microphone(capture)
		
		# Lock mutex to update latest_midi in a thread-safe manner.
		pitch_mutex.lock()
		latest_midi = midi
		pitch_mutex.unlock()
		
		OS.delay_msec(msec_delay)

func _process(delta):
	# Safely retrieve the latest midi value and update accordingly.
	pitch_mutex.lock()
	var midi = latest_midi
	pitch_mutex.unlock()
	
	if midi != latest_midi_main:
		latest_midi_main = midi
		midi_updated.emit(midi)
		#print("Detected pitch:", midi)
