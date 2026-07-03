extends Node

const MAX_TRACK_COUNT 	: 	int = 4
const MIN_TRACK_COUNT	: 	int = 2
var TRACK_COUNT			: 	int = MAX_TRACK_COUNT # Default Value

var globalOffset : float = 0.0

var scrollSpd : float = 5.0

var currentChartPath : String

var currentChartMetaData : Array

var currentScore : int

var currentMaxCombo : int
