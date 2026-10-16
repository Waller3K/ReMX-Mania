extends Node

## The origin where the default charts come from
const DEFAULT_CHART_SOURCE : String = "res://Charts/"
## The default chart directory that resides in the 
## OS's AppData folder. 
const CHARTS_DEST : String = "user://Charts"
## The number of note object in the note spawn pool
const 	NOTE_POOL_SIZE	: 	int 	= 50
## The maximum number of tracks allowed in the game
const 	MAX_TRACK_COUNT : 	int 	= 4
## The minimum number of tracks allowed in the game
const 	MIN_TRACK_COUNT	: 	int 	= 2
## The length of time before the song starts. This 
## places the song position variable at -n where
## n is this value at the start of the chart.
const 	PRESONG_TIME	: 	float 	= 5.0 # In seconds
## The length of the time after the song finishes.
## This value is used to create a timer that starts 
## right as the chart ends.
const 	POSTSONG_TIME	:	float 	= 3.0 # In seconds
## The maxium possible technical/unweighted score value
const 	MAXIMUM_SCORE	: int	= 1000000

## The amount of time *(in seconds)* between slider 
## and long scratch ticks.  
const 	TICK_INTERVAL	:	float 	= 0.1 # In seconds

## The Current Release Version of the game! Remember to change this
## before any release on github! 
## 0.01 - 0.09 is Pre-Alpha
## 0.1 - 0.9 is Alpha and Beta
## 1.0 + is final release!
const	VERSION	 		:	float	= 0.012 # Pre-Alpha 1.2

var isDebug : bool = true

#The timing window variables (Hard coded for now) in ms
var perfectTiming: float		= 16.67
var almostPerfectTiming: float	= 33.00
var goodTiming: float			= 92.00
var okTiming: float				= 200.00

## The combo needed to reach a 2x score multiplier
var twoXBoundary  	: int 	= 10
## The combo needed to reach a 3x score multiplier
var threeXBoundary 	: int 	= 25
## The combo needed to reach a 4x score multiplier
var fourXBoundary 	: int 	= 50

## The amount of time the notes in all charts are either
## pushed forward or backward depending on the player's
## audio delay.
var globalOffset : float = 0.0

var scrollSpd : float = 2.0

var musicVolumeDB : float = 0.0
var sfxVolumeDB : float = 0.0

var scratchDeadzone : float = 5.0

var currentChartPath : String
var currentChartData : Chart = null

## Variable for the volume offset to prevent clipping
var streamDBOffset : float = 10.0

var currentResults : Results

var chartDirectories : Array[String] = [
	CHARTS_DEST
]

# An array of non FC grades that 
var gradeThresholds : Array[float] = [
	0.5,  	# F
	0.55, 	# D
	0.6,  	# C
	0.7,  	# CC
	0.78, 	# B
	0.8,  	# BB
	0.85, 	# BBB
	0.9,  	# A
	0.95, 	# AA
	1.0  	# AAA
]

var mainTrackXPos : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var mainNoteWidth : float = 0.0
var scratchNoteWidth : float = 0.0

#Global Functions

## A simple function that takes the chart files from the .pck file,
## and creates a default Charts directory in the user folder on first
## launch.
func installDefaultCharts():
	# If the marker file exists, check the version of the file.
	if FileAccess.file_exists(GlobalStates.CHARTS_DEST + "/.defaultChartsInstalled"):
		var markerFile := FileAccess.open(GlobalStates.CHARTS_DEST + "/.defaultChartsInstalled", FileAccess.READ)
		if markerFile.eof_reached():
			print("markerFile Empty! Updating charts...")
		else:
			var version = markerFile.get_float()
			# Using snappedf() to deal with floating point imprecision.
			if snappedf(version, 0.0001) == GlobalStates.VERSION:
				return
			else:
				print("Version Mismatch, Current Game Version is '"
				+ str(GlobalStates.VERSION)
				+ "' markerFile Version is '"
				+ str(version)
				+ "'. Updating charts...")
		clearDirRecursive(GlobalStates.CHARTS_DEST)
	
	copyDirRecursive(GlobalStates.DEFAULT_CHART_SOURCE, GlobalStates.CHARTS_DEST)
	
	# NOTE: FILEACCESS.WRITE truncates the file and overwrites its contents.
	var marker := FileAccess.open(GlobalStates.CHARTS_DEST + "/.defaultChartsInstalled", FileAccess.WRITE)
	marker.store_float(GlobalStates.VERSION)
	marker.close()

## A helper function that recursively goes through a directory and
## clears it out.
func clearDirRecursive(path : String):
	for dir in DirAccess.get_directories_at(path):
		clearDirRecursive(path.path_join(dir))
	
	for file in DirAccess.get_files_at(path):
		DirAccess.remove_absolute(path.path_join(file))
	
	DirAccess.remove_absolute(path)

## A helper function that goes through a directory and copies 
## all of the contents of said directory to another.
func copyDirRecursive(from : String, to : String):
	DirAccess.make_dir_recursive_absolute(to)
	var dir = DirAccess.open(from)
	dir.list_dir_begin()
	var itemName = dir.get_next()
	while itemName != "":
		if itemName.begins_with("."):
			itemName = dir.get_next()
			continue
		var fromPath = from + "/" + itemName
		var toPath = to + "/" + itemName
		if dir.current_is_dir():
			copyDirRecursive(fromPath, toPath)
		else:
			DirAccess.copy_absolute(fromPath, toPath)
		itemName = dir.get_next()
	dir.list_dir_end()
