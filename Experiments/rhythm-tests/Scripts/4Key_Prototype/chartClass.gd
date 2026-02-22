class_name Chart
extends Resource

# Song Metadata Variables

@export var bpm: 		float
@export var songPath: 	String
@export var songName: 	String
@export var songArtist:	String
@export var charter: 	String
@export var difficulty:	float

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
	songPath 		= chartData["Metadata"]["path"]
	songName		= chartData["Metadata"]["name"]
	songArtist		= chartData["Metadata"]["artist"]
	charter			= chartData["Metadata"]["charter"]
	difficulty		= chartData["Metadata"]["difficulty"]
	track1Path		= chartData["Metadata"]["track1Path"]
	track2Path		= chartData["Metadata"]["track2Path"]
	track3Path		= chartData["Metadata"]["track3Path"]
	track4Path		= chartData["Metadata"]["track4Path"]
	notes.track1 	= chartData["Notes"]["Track 1"]
	notes.track2 	= chartData["Notes"]["Track 2"]
	notes.track3 	= chartData["Notes"]["Track 3"]
	notes.track4 	= chartData["Notes"]["Track 4"]
	
	print("Chart loaded successfully")
	
	return true
