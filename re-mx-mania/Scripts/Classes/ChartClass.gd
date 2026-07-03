class_name Chart
extends Resource

# Song Metadata Variables

@export var bpm 			:	float
@export var BGMPath 		:	String
@export var songName		:	String
@export var songArtist		:	String
@export var charter			:	String
@export var difficultyName	:	String
@export var difficulty		:	float

# Chart Metadata Variables
#################################################
# These variables will always remain seperate as 
# There should always be 4 main audio tracks!
#################################################
@export var trackCount: int
@export var track1Path: String
@export var track2Path: String
@export var track3Path: String
@export var track4Path: String
@export var scratchTrackPath: String

#####################################################
# Main Track Note Array. A 2D Array that contains 
# the tracks and their notes. The tracks are 
# the same way as they are in GlobalEnums.trackIDs
#####################################################
@export var mainNotes : Array[Array]

# Scratch Track Note Array. 
@export var scratchNotes : Array[Dictionary]

func load(path: String) -> bool:
	
	# Checks if the file path is valid 
	if not FileAccess.file_exists(path):
		print("Error: File path invalid '" + path + "'!")
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
	
	# sets the song metadata
	bpm				= chartData["Metadata"]["BPM"]
	BGMPath			= chartData["Metadata"]["BGMPath"]
	songName		= chartData["Metadata"]["Title"]
	songArtist		= chartData["Metadata"]["Artist"]
	charter			= chartData["Metadata"]["Charter"]
	difficultyName	= chartData["Metadata"]["DifficultyName"]
	difficulty		= chartData["Metadata"]["Difficulty"]
	track1Path		= chartData["Metadata"]["Track1Path"]
	track2Path		= chartData["Metadata"]["Track2Path"]
	track3Path		= chartData["Metadata"]["Track3Path"]
	track4Path		= chartData["Metadata"]["Track4Path"]
	
	#The trackCount is the number of main tracks in this chart!
	if (chartData["Metadata"]["TrackCount"] > GlobalStates.MAX_TRACK_COUNT or 
		chartData["Metadata"]["TrackCount"] < GlobalStates.MIN_TRACK_COUNT):
		print("Chart Error: Invalid Track Count: '" 
		+ chartData["Metadata"]["TrackCount"]
		+ "'!")
		return false
	trackCount		= chartData["Metadata"]["TrackCount"]
	
	var trackNames : Array = chartData["Notes"].keys()
	
	# This section adds the main track notes and the FX notes to the 2D array
	# Plus 1 because the FX track isn't counted in the trackCount
	for track in trackCount + 1:
		mainNotes.push_back(chartData["Notes"][trackNames[track]])
	
	return true
