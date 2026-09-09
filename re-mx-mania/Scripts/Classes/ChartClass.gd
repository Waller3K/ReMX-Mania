class_name Chart
extends Resource

# Song Metadata Variables

@export var bpm 			:	float
@export var BGMPath 		:	String
@export var songName		:	String
@export var songNameRom 	:	String # Romanized version of songName
@export var songArtist		:	String
@export var songArtistRom	:	String # Romanized version of songArtist
@export var charter			:	String
@export var difficultyName	:	String
@export var difficulty		:	float

# Chart Metadata Variables
#################################################
# These variables will always remain seperate as 
# There should always be 4 main audio tracks!
#################################################

## Number of main tracks
@export var trackCount: int

## An array of track paths ordered in the same way as GlobalEnums.trackIDs
@export var trackPaths: Array[String] = []

## The place the music starts playing from when the player opens the chart in
## song select menu!
@export var previewTimestamp: float

## path to the scratch track audio!
@export var scratchTrackPath: String

## path to the current chart!
@export var chartPath : String


## Main Track Note Array. A 2D Array that contains 
## the tracks and their notes. The tracks are 
## in the same way order as they are in GlobalEnums.trackIDs.
## The notes are accessed like this :
## notes[TrackID][NoteIndex]["Section"]
@export var notes : Array[Array]

## The total number of scorable notes in the chart
@export var numOfNotes : int

## Returns the path to this chart
func getPath() -> String:
	return chartPath

## Returns the length of the passed in note. Takes in the note's track ID and its
## index.
## NOTE: Only works on main track notes and FX notes. Scratch track subnotes are excluded
func getNoteLength(trackID : GlobalEnums.trackIDs, noteIndex : int) -> float:
	var note : Dictionary = notes[trackID][noteIndex]
	if note == null:
		push_error("Error: Invalid note passed to getNoteLength() :" + str(trackID) + ", " + str(noteIndex))
		return -1.0
	
	if note.has("End"):
		var length : float = note["End"] - note["Pos"]
		return length
	
	return 0.0

## Loads the chart data from a valid chart.json file at the given path. Returns true if chart is
## parsed successfully and false if not.
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
	bpm				 = chartData["Metadata"]["BPM"]
	BGMPath			 = chartData["Metadata"]["BGMPath"]
	songName		 = chartData["Metadata"]["Title"]
	songArtist		 = chartData["Metadata"]["Artist"]
	charter			 = chartData["Metadata"]["Charter"]
	difficultyName	 = chartData["Metadata"]["DifficultyName"]
	difficulty		 = chartData["Metadata"]["Difficulty"]
	scratchTrackPath = chartData["Metadata"]["ScratchPath"]
	trackPaths.append(chartData["Metadata"]["Track1Path"]) 
	trackPaths.append(chartData["Metadata"]["Track2Path"]) 
	trackPaths.append(chartData["Metadata"]["Track3Path"]) 
	trackPaths.append(chartData["Metadata"]["Track4Path"]) 
	previewTimestamp = chartData["Metadata"]["Preview"]
	
	if chartData.has("TitleRomanized"):
		songNameRom = chartData["Metadata"]["TitleRomanized"]
	
	if chartData.has("ArtistRomanized"):
		songArtistRom = chartData["Metadata"]["ArtistRomanized"]
	
	
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
	# Plus 2 because the FX track isn't counted in the trackCount and neither
	# is Scratch Track
	# THE TRACKS SHOULD ALWAYS BE IN THE SAME ORDER AS THE TRACKIDS
	for track in trackCount + 2:
		notes.push_back(chartData["Notes"][trackNames[track]])
	
	chartPath = path
	
	for track : Array[Dictionary] in notes:
		for note : Dictionary in track:
			# If the note is a hold it counts as 2 notes
			if note.has("End"):
				numOfNotes += 2
				
				if note.has("Subnotes"):
					for subNotes in note["Subnotes"]:
						numOfNotes += 1
				continue
			
			numOfNotes += 1
	
	#print("Number of notes: " + str(numOfNotes))
	
	return true

## A simple helper function that deturmines if the inputed text is made up of just ASCII characters!
func isASCII(input : String) -> bool:
	## A simple RegEX that returns true only when the input is purely made up of Ascii characters!
	var asciiRegEX = RegEx.create_from_string("^[[:ascii:]\\s]*$")
	
	if asciiRegEX.search(input) != null:
		return true
	
	return false

## Takes the current chart data and exports it as a chart.json file in the given directory!
func save(path : String):
	# Checks if the directory is valid
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Failed to open directory with chart.save()! Error:" + str(DirAccess.get_open_error()))
		return
	
	var titleNeedRomanization : bool = isASCII(songName)
	var artistNeedRomanization : bool = isASCII(songArtist)
	
	
	var chartData : Dictionary = {
		"Metadata" : {
			"Title" 			: songName,
			"Artist" 			: songArtist,
			"Charter" 			: charter,
			"DifficultyName" 	: difficultyName,
			"Difficulty" 		: difficulty,
			"Preview"			: previewTimestamp,
			"TrackCount"		: trackCount,
			"BPM"				: bpm,
			"BGMPath"			: BGMPath,
			"ScratchPath"		: scratchTrackPath,
			"Track1Path"		: trackPaths[0],
			"Track2Path"		: trackPaths[1],
			"Track3Path"		: trackPaths[2],
			"Track4Path"		: trackPaths[3]
		},
		"Notes" : {
			"Track FX" : notes[0],
			"Scratch Track" : notes[1]
		}
	}
	
	var trackNames = [
		"Track 1",
		"Track 2",
		"Track 3",
		"Track 4"
	]
	
	for track in range(trackCount):
		chartData["Notes"][trackNames[track]] = notes[track + 2] # Plus 2 to skip Track FX and Scratch Track
	
	if titleNeedRomanization:
		chartData["TitleRomanized"] = songNameRom
	
	if artistNeedRomanization:
		chartData["ArtistRomanized"] = songArtistRom
	
	var filename = difficultyName + ".json"
	
	var outputJson = FileAccess.open((path + filename), FileAccess.WRITE)
	
	if outputJson:
		var jsonString = JSON.stringify(chartData, "\t")
		
		outputJson.store_string(jsonString)
		outputJson.close()
		print("Chart Saved to: ", path)
	else:
		print("Failed to open file! Error code: ", FileAccess.get_open_error())
