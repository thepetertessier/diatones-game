extends Node

@onready var note_spawner: Node2D = %NoteSpawner
@onready var key_manager: Node2D = %KeyManager
@onready var time_signature_manager: Node2D = %TimeSignatureManager
@onready var clef_manager: Node2D = %ClefManager
@onready var conductor: Node = %Conductor

enum {TREBLE, TENOR, BASS}

# Helper function to read text content from the current element.
func read_text(parser: XMLParser) -> String:
	var result = ""
	# Keep reading until we hit an end element.
	while parser.read() == OK:
		var node_type = parser.get_node_type()
		if node_type == XMLParser.NODE_TEXT:
			result += parser.get_node_data().strip_edges()
		elif node_type == XMLParser.NODE_ELEMENT_END:
			break
	return result

func sign_and_line_to_clef(sign: String, line: int, clef_octave_change: int):
	if sign == 'G' and line == 2:
		if clef_octave_change == -1:
			return TENOR
		elif clef_octave_change == 0:
			return TREBLE
	if sign == 'F' and line == 4 and clef_octave_change == 0:
		return BASS
	# Should not get here
	assert(false)

func parse_musicxml(path_to_musicxml: String) -> Dictionary:
	var parser = XMLParser.new()
	parser.open(path_to_musicxml)

	var representation = {
		"key": null,
		"time_signature": null,
		"clef": null,
		"divisions": null,  # How many "ticks" in a quarter note
		"bpm": null,
		"notes": [],
	}

	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var element_name = parser.get_node_name()
			
			if element_name == "key":
				# Look for <fifths> inside <key>
				while parser.read() == OK:
					if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "fifths":
						representation["key"] = int(read_text(parser))
					elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "key":
						break
						
			elif element_name == "time":
				var beats = ""
				var beat_type = ""
				while parser.read() == OK:
					if parser.get_node_type() == XMLParser.NODE_ELEMENT:
						var name = parser.get_node_name()
						if name == "beats":
							beats = int(read_text(parser))
						elif name == "beat-type":
							beat_type = int(read_text(parser))
					elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "time":
						break
				representation["time_signature"] = {"beats": beats, "beat_type": beat_type}
			
			elif element_name == "clef":
				var sign = ""
				var line = 0
				var clef_octave_change = 0
				while parser.read() == OK:
					if parser.get_node_type() == XMLParser.NODE_ELEMENT:
						var name = parser.get_node_name()
						if name == "sign":
							sign = read_text(parser)
						elif name == "line":
							line = int(read_text(parser))
						elif name == "clef-octave-change":
							clef_octave_change = int(read_text(parser))
					elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "clef":
						break
				representation["clef"] = sign_and_line_to_clef(sign, line, clef_octave_change)
				
			elif element_name == "divisions":
				# e.g. <divisions>2</divisions>
				representation["divisions"] = int(read_text(parser))
				
			elif element_name == "sound":
				if parser.has_attribute("tempo"):
					representation["bpm"] = float(parser.get_attribute_value(0))
				# Skip this element if needed
				# (Read until end of <sound>)
				while parser.get_node_type() != XMLParser.NODE_ELEMENT_END or parser.get_node_name() != "sound":
					if parser.read() != OK:
						break
			
			elif element_name == "direction":
				# Look for BPM info inside a <direction> element.
				while parser.read() == OK:
					if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "metronome":
						while parser.read() == OK:
							if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "per-minute":
								representation["bpm"] = float(read_text(parser))
							elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "metronome":
								break
					elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "direction":
						break
						
			elif element_name == "note":
				var note_info = {
					"pitch": null,
					"duration": null,
					"is_rest": false
				}
				while parser.read() == OK:
					if parser.get_node_type() == XMLParser.NODE_ELEMENT:
						var child_name = parser.get_node_name()
						if child_name == "rest":
							note_info["is_rest"] = true
							# Read until end of <rest> to avoid issues.
							while parser.read() != OK:
								if parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "rest":
									break
						elif child_name == "pitch":
							var pitch = {"step": "", "alter": 0, "octave": 0}
							while parser.read() == OK:
								if parser.get_node_type() == XMLParser.NODE_ELEMENT:
									var pitch_child = parser.get_node_name()
									if pitch_child == "step":
										pitch["step"] = read_text(parser)
									elif pitch_child == "alter":
										pitch["alter"] = int(read_text(parser))
									elif pitch_child == "octave":
										pitch["octave"] = int(read_text(parser))
								elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "pitch":
									break
							note_info["pitch"] = pitch
						elif child_name == "duration":
							note_info["duration"] = int(read_text(parser))
					elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "note":
						break
				representation["notes"].append(note_info)
	
	#print(representation)
	validate_representation(representation)
	return representation

func validate_representation(representation):
	if not representation["bpm"]:
		printerr("BPM is not set in MusicXML")
		assert(false)
