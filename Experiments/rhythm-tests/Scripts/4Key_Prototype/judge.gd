extends Node
#############################################
# These signals would both show the final
# judgement of the hit, and also the amount 
# of miliseconds away from either note 
# they are "offset"
#############################################

signal okEarly(offset: float, trackIndex: int, noteIndex: int)
signal goodEarly(offset: float, trackIndex: int, noteIndex: int)
signal perfectEarly(offset: float, trackIndex: int, noteIndex: int)
signal perfect(offset: float, trackIndex: int, noteIndex: int)
signal perfectLate(offset: float, trackIndex: int, noteIndex: int)
signal goodLate(offset: float, trackIndex: int, noteIndex: int)
signal okLate(offset: float, trackIndex: int, noteIndex: int)
signal miss(trackIndex: int, noteIndex: int) # The miss signal is the only one that won't have an offset

var noteData: Dictionary

var songPos: float

#Iterators for each track
var track1NextNoteIndex = 0
var track2NextNoteIndex = 0
var track3NextNoteIndex = 0
var track4NextNoteIndex = 0

#Track ended booleans
var track1Ended = false
var track2Ended = false
var track3Ended = false
var track4Ended = false

#Track Button States
var BTN_1 = false
var BTN_2 = false
var BTN_3 = false
var BTN_4 = false
var BTN_FX = false

#Track Last Note Hit booleans
var track1LNH = false
var track2LNH = false
var track3LNH = false
var track4LNH = false

#The timing window variables (Hard coded for now) in ms
var perfectTiming: float		= 16.67
var almostPerfectTiming: float	= 33.00
var goodTiming: float			= 92.00
var okTiming: float				= 200.00

#############################################
# The functionality of this component would 
# all happen within this onRhythmUpdate() 
# function that comes from the conductor component's 
# rhythmUpdate() signal
#############################################

func _onSongUpdate(timeStamp):
	songPos = timeStamp * 1000
	updateNextNote(songPos)
#############################################
# Updates the next note index when we pass
# a note and sets the variables for ending the 
# tracks
#############################################
func updateNextNote(timeStamp: float) -> void:
	
	# Track 1
	if track1Ended:
		pass
	elif noteData.track1.is_empty():
		track1Ended = true;
	elif timeStamp > noteData.track1[track1NextNoteIndex]["Pos"] * 1000 + okTiming and track1LNH != true:
		miss.emit(GE.inputEnum.TRACK1, track1NextNoteIndex)
		if track1NextNoteIndex + 1 < noteData.track1.size():
			track1NextNoteIndex += 1
		else:
			track1Ended = true
	# Track 2
	if track2Ended:
		pass
	elif noteData.track2.is_empty():
		track2Ended = true;
	elif timeStamp >= noteData.track2[track2NextNoteIndex]["Pos"] * 1000 + okTiming and track2LNH != true:
		miss.emit(GE.inputEnum.TRACK2, track2NextNoteIndex)
		if track2NextNoteIndex + 1 < noteData.track2.size():
			track2NextNoteIndex += 1
		else:
			track2Ended = true
	# Track 3
	if track3Ended:
		pass
	elif noteData.track3.is_empty():
		track3Ended = true;
	elif timeStamp >= noteData.track3[track3NextNoteIndex]["Pos"] * 1000 + okTiming and track3LNH != true:
		miss.emit(GE.inputEnum.TRACK3, track3NextNoteIndex)
		if track3NextNoteIndex + 1 < noteData.track3.size():
			track3NextNoteIndex += 1
		else:
			track3Ended = true
	# Track 4
	if track4Ended:
		pass
	elif noteData.track4.is_empty():
		track4Ended = true;
	elif timeStamp > noteData.track4[track4NextNoteIndex]["Pos"] * 1000 + okTiming and track4LNH != true:
		miss.emit(GE.inputEnum.TRACK4, track4NextNoteIndex)
		if track4NextNoteIndex + 1 < noteData.track4.size():
			track4NextNoteIndex += 1
		else:
			track4Ended = true

####################################################
# The main judgement logic will be done here.
# This function returns the updated nextNoteIndex! 
# This is a workaround due to Godot copying ints by 
# value and not by reference
####################################################
func judge(inputTime:float, inputIndex: int, input: bool, nextNoteIndex: int, track: Array) -> int:
	
	var isLate: bool
	
	var trackEnded: bool = false
	
	if track.is_empty():
		return nextNoteIndex
	
	if nextNoteIndex == track.size() - 1:
		trackEnded = true
		
	
	var nextNotePosition = track[nextNoteIndex]["Pos"] * 1000 #Multiplied by 1000 to convert from sec - ms
	
	var offset: float = inputTime - nextNotePosition
	
	#############################################
	# Checks to see if the note was hit early or
	# Late
	#############################################
	
	if inputTime - nextNotePosition > 0:
		isLate = true
	
	if input == false:
		return nextNoteIndex
	
	if abs(inputTime - nextNotePosition) <= perfectTiming:
		perfect.emit(offset, inputIndex, nextNoteIndex)	
		if trackEnded:
			lastNoteHit(inputIndex)
		#############################################
		# This line only increments the next note
		# if the track hasn't ended
		#############################################
		return nextNoteIndex if trackEnded else nextNoteIndex + 1
	
	elif abs(inputTime - nextNotePosition) <= almostPerfectTiming:
		if isLate:
			perfectLate.emit(offset, inputIndex, nextNoteIndex)
		else:
			perfectEarly.emit(offset, inputIndex, nextNoteIndex)
		if trackEnded:
			lastNoteHit(inputIndex)
		return nextNoteIndex if trackEnded else nextNoteIndex + 1
		
	elif abs(inputTime - nextNotePosition) <= goodTiming:
		if isLate:
			goodLate.emit(offset, inputIndex, nextNoteIndex)
		else:
			goodEarly.emit(offset, inputIndex, nextNoteIndex)
		if trackEnded:
			lastNoteHit(inputIndex)
		return nextNoteIndex if trackEnded else nextNoteIndex + 1
	
	elif abs(inputTime - nextNotePosition) <= okTiming:
		if isLate:
			okLate.emit(offset, inputIndex, nextNoteIndex)
		else:
			okEarly.emit(offset, inputIndex, nextNoteIndex)
		if trackEnded:
			lastNoteHit(inputIndex)
		return nextNoteIndex if trackEnded else nextNoteIndex + 1
	
	return nextNoteIndex

func lastNoteHit(trackIndex: int):
	match trackIndex:
		GE.inputEnum.TRACK1:
			track1LNH = true
		GE.inputEnum.TRACK2:
			track2LNH = true
		GE.inputEnum.TRACK3:
			track3LNH = true
		GE.inputEnum.TRACK4:
			track4LNH = true

func _onChartCreation(chart):
	noteData = chart.notes

# Signal functions from input component
func _onBTN_1(inputTime, isDown):
	BTN_1 = isDown
	track1NextNoteIndex = judge(inputTime, GE.inputEnum.TRACK1, BTN_1, track1NextNoteIndex, noteData.track1)


func _onBTN_2(inputTime, isDown):
	BTN_2 = isDown
	track2NextNoteIndex = judge(inputTime, GE.inputEnum.TRACK2, BTN_2, track2NextNoteIndex, noteData.track2)

func _onBTN_3(inputTime, isDown):
	BTN_3 = isDown
	track3NextNoteIndex = judge(inputTime, GE.inputEnum.TRACK3, BTN_3, track3NextNoteIndex, noteData.track3)


func _onBTN_4(inputTime, isDown):
	BTN_4 = isDown
	track4NextNoteIndex = judge(inputTime, GE.inputEnum.TRACK4, BTN_4, track4NextNoteIndex, noteData.track4)


func _onBTN_FX(_inputTime, isDown):
	BTN_FX = isDown
	#judge(GE.inputEnum.TRACK1, BTN_FX, trackFXNextNoteIndex, noteData.trackFX)
