extends Node

class_name Chart

# Song Metadata Variables

var bpm: 		float
var songPath: 	String
var songName: 	String
var songArtist:	String
var charter: String
var difficulty:	float

# Chart Metadata Variables
var track1Path: String # the paths to the stems controlled by each track
var track2Path: String
var track3Path: String
var track4Path: String
var scratchTrackPaths = [] # an array of sample paths used by scratch track

# Note dictionary which will contain the individual track's notes in arrays
var notes = {
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
	
	
	
	
	return true
