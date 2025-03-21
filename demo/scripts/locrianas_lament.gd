extends Node

const REST := -999
const QUARTER := 12
const EIGHTH := 6

var song_data := {
	"key": -3,
	"time_signature": {"beats": 4, "beat-type": 4},
	"notes": [
		note(REST, QUARTER*3),
		note(50, EIGHTH),
		note(51, EIGHTH),
		
		note(62, QUARTER),
		note(63, QUARTER),
		note(58, QUARTER),
		note(50, EIGHTH),
		note(51, EIGHTH),
		
		note(60, QUARTER),
		note(61, QUARTER),
		note(56, EIGHTH*3),
		note(56, EIGHTH),
		
		note(55, QUARTER*2),
		note(REST, QUARTER*2),
		
		note(REST, QUARTER*2),
		note(50, QUARTER),
		note(51, QUARTER),
		
		note(62, QUARTER),
		note(63, QUARTER),
		note(58, QUARTER),
		note(50, EIGHTH),
		note(51, EIGHTH),
		
		note(60, QUARTER),
		note(61, QUARTER),
		note(56, EIGHTH*3),
		note(56, EIGHTH),
		
		note(55, QUARTER*3),
		note(REST, QUARTER*1),
		
		note(54, QUARTER*2),
		note(REST, QUARTER*2),
	]
}

func note(midi: int, duration: int):
	# Make it so that duration of 4*3=12 is a one beat
	return {"midi": midi, "duration": duration}
