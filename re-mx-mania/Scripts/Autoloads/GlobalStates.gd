extends Node

const 	NOTE_POOL_SIZE	: 	int 	= 50
const 	MAX_TRACK_COUNT : 	int 	= 4
const 	MIN_TRACK_COUNT	: 	int 	= 2
var 	PRESONG_TIME	: 	float 	= 3.0 # In seconds
var 	TRACK_COUNT		: 	int 	= MAX_TRACK_COUNT # Default Value

#The timing window variables (Hard coded for now) in ms
var perfectTiming: float		= 16.67
var almostPerfectTiming: float	= 33.00
var goodTiming: float			= 92.00
var okTiming: float				= 200.00

var globalOffset : float = 0.0

var scrollSpd : float = 2.0

var scratchDeadzone : float = 5.0

var currentChartPath : String

var currentScore : int

var currentMaxCombo : int

var chartDirectories : Array[String] = [
	"res://Charts"
]

var mainTrackXPos : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var mainNoteWidth : float = 0.0
var scratchNoteWidth : float = 0.0
