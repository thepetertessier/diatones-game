extends PitchDetector
# Responsible for emitting the midi updated from microphone
# And db updated

signal midi_updated(new_midi: float)
signal db_updated(new_db: float)

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

var latest_db: float = -80.0
var latest_db_main: float = -80.0
var db_mutex := Mutex.new()

func _ready():
	# Set up thread
	thread = Thread.new()
	thread.start(thread_function)

func get_midi(audio_buffer):
	return detect_midi(audio_buffer, sample_rate, min_frequency, max_frequency)

func get_midi_and_db_from_microphone(capture) -> Vector2:
	if capture and capture.can_get_buffer(buffer_size):
		var audio_buffer = capture.get_buffer(buffer_size)
		var midi: float = get_midi(audio_buffer)
		midi += 1.3 # Manual adjustment
		
		var db = get_db_from_audio_buffer(audio_buffer)
		return Vector2(midi, db)
	return Vector2(-999, -80.0)

func get_db_from_audio_buffer(audio_buffer: PackedVector2Array) -> float:
	var peak := 0.0
	
	for sample in audio_buffer:
		# Convert stereo to mono
		var mono := (sample.x + sample.y) * 0.5
		var abs_val = abs(mono)
		if abs_val > peak:
			peak = abs_val

	# Avoid log(0) — return minimum dB if silent
	if peak < 0.00001:
		return -80.0
	
	# Use log10 approximation (faster than Godot's built-in log10)
	var db := 20.0 * (log(peak) / log(10.0))
	return db

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	thread_should_stop = true
	thread.wait_to_finish()

func thread_function():
	const CAPTURE_EFFECT_IDX = 1
	var mic_bus_index = AudioServer.get_bus_index("Microphone")
	var capture = AudioServer.get_bus_effect(mic_bus_index, CAPTURE_EFFECT_IDX) as AudioEffectCapture
	
	while not thread_should_stop:
		var midi_and_db = get_midi_and_db_from_microphone(capture)
		var midi = midi_and_db.x
		var db = midi_and_db.y
		
		# Lock mutex to update latest_midi in a thread-safe manner.
		pitch_mutex.lock()
		latest_midi = midi
		pitch_mutex.unlock()
		
		db_mutex.lock()
		latest_db = db
		db_mutex.unlock()
		
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
	
	db_mutex.lock()
	var db = latest_db
	db_mutex.unlock()
	
	if db != latest_db_main:
		latest_db_main = db
		db_updated.emit(db)
