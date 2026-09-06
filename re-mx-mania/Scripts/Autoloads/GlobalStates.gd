extends Node

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
var currentChartData : Chart

## Variable for the volume offset to prevent clipping
var streamDBOffset : float = 10.0

var currentResults : Results

var chartDirectories : Array[String] = [
	"C:/Users/waltl/Desktop/Code_n_stuff/Godot/Projects/ReMX Mania/re-mx-mania/Charts"
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
