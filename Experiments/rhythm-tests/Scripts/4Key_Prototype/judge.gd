extends Node
#############################################
# These signals would both show the final
# judgement of the hit, and also the amount 
# of miliseconds away from either note 
# they are "offset"
#############################################

signal okEarly(offset: float)
signal goodEarly(offset: float)
signal perfect(offset: float)
signal goodLate(offset: float)
signal okLate(offset: float)
signal miss # The miss signal is the only one that won't have an offset

var noteData

#Iterators for each track
var track1NextNoteIndex = 0
var track2NextNoteIndex = 0
var track3NextNoteIndex = 0
var track4NextNoteIndex = 0

#Note Hit Booleans
var track1NextNoteHit = false
var track2NextNoteHit = false
var track3NextNoteHit = false
var track4NextNoteHit = false


#############################################
# The functionality of this component would 
# all happen within this onRhythmUpdate() 
# function that comes from the conductor component's 
# rhythmUpdate() signal
#############################################

func _onRhythmUpdate(timeStampInBeats):
	if timeStampInBeats >= noteData["Track 1"][track1NextNoteIndex]["Pos"] and track1NextNoteHit == false:
		print("Miss!")


func _onChartCreation(chart):
	noteData = chart.notes
