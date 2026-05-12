class_name Chart
extends Resource

# Song Metadata Variables

@export var bpm: 			float
@export var BGMPath: 		String
@export var songName: 		String
@export var songArtist:		String
@export var charter: 		String
@export var difficultyName: String
@export var difficulty:		float

# Chart Metadata Variables
@export var track1Path: String # the paths to the stems controlled by each track
@export var track2Path: String
@export var track3Path: String
@export var track4Path: String
@export var scratchTrackPaths = [] # an array of sample paths used by scratch track

# Note dictionary which will contain the individual track's notes in arrays
@export var notes = {
	track1 = [],
	track2 = [],
	track3 = [],
	track4 = [],
	trackFX = [],
	trackScratch = []
}

##########################################################
# This function takes in a path to a JSON file 
# and initializes all of the chart values so that they can
# be used by other scripts. Returns true if it was sucessful,
# and false on failure
##########################################################
func load(path: String) -> bool:
	
	# Checks if the file path is valid
	if not FileAccess.file_exists(path):
		print("Error: File path invalid")
		return false
	
	# Opens Json file and parses it
	var jsonStream: FileAccess = FileAccess.open(path, FileAccess.READ)
	
	var jsonString: String = jsonStream.get_as_text()
	
	jsonStream.close()
	
	var chartData = JSON.parse_string(jsonString)
	
	# Checking if JSON string was properly parsed
	if chartData == null:
		print("Error: JSON data could not be parsed!")
		return false
	
	# Sets the chart variables using the JSON chart data
	
	bpm 			= chartData["Metadata"]["BPM"]
	BGMPath 		= chartData["Metadata"]["BGMPath"]
	songName		= chartData["Metadata"]["Title"]
	songArtist		= chartData["Metadata"]["Artist"]
	charter			= chartData["Metadata"]["Charter"]
	difficultyName	= chartData["Metadata"]["Charter"]
	difficulty		= chartData["Metadata"]["Difficulty"]
	track1Path		= chartData["Metadata"]["Track1Path"]
	track2Path		= chartData["Metadata"]["Track2Path"]
	track3Path		= chartData["Metadata"]["Track3Path"]
	track4Path		= chartData["Metadata"]["Track4Path"]
	notes.track1 	= chartData["Notes"]["Track 1"]
	notes.track2 	= chartData["Notes"]["Track 2"]
	notes.track3 	= chartData["Notes"]["Track 3"]
	notes.track4 	= chartData["Notes"]["Track 4"]
	notes.trackFX	= chartData["Notes"]["Track FX"]
	
	# Updates global state for current chart path and metadata
	GlobalStates.currentChartPath = path
	GlobalStates.currentChartMetadata = chartData["Metadata"]
	GlobalStates.currentScore = 0
	
	# Adds a has been hit bool to each note on each track
	
	for note in notes.track1:
		note.set("beenHit", false)
	
	for note in notes.track2:
		note.set("beenHit", false)
	
	for note in notes.track3:
		note.set("beenHit", false)
	
	for note in notes.track4:
		note.set("beenHit", false)
	
	for note in notes.trackFX:
		note.set("beenHit", false)

	print("Chart loaded successfully")
	
	return true
