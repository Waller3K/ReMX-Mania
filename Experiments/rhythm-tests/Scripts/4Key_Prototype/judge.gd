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

#var songSPB: float #Song seconds per beat
var songPos: float

#Iterators for each track
var track1NextNoteIndex = 0
var track1LastNoteIndex = -1

var track2NextNoteIndex = 0
var track2LastNoteIndex = -1

var track3NextNoteIndex = 0
var track3LastNoteIndex = -1

var track4NextNoteIndex = 0
var track4LastNoteIndex = -1

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

#The timing window variables (Hard coded for now) in ms
var perfectTiming: float			= 16.67
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
	#songSPB = secondsPerBeat
	songPos = timeStamp * 1000
	print(str(track4NextNoteIndex))
	updateNextNote(songPos)
#############################################
# Updates the next note index when we pass
# a note and sets the variables for ending the 
# tracks
#############################################
func updateNextNote(timeStamp: float) -> void:
	
	# Track 1
	if noteData.track1.is_empty():
		track1Ended = true;
	elif timeStamp > noteData.track1[track1NextNoteIndex]["Pos"] * 1000 + okTiming:
		#miss.emit(GE.inputEnum.TRACK1, track1NextNoteIndex)
		if track1NextNoteIndex + 1 < noteData.track1.size():
			track1NextNoteIndex += 1
		else:
			track1Ended = true
	# Track 2
	if noteData.track2.is_empty():
		track2Ended = true;
	elif timeStamp >= noteData.track2[track2NextNoteIndex]["Pos"] * 1000 + okTiming:
		#miss.emit(GE.inputEnum.TRACK2, track2NextNoteIndex)
		if track2NextNoteIndex + 1 < noteData.track2.size():
			track2NextNoteIndex += 1
		else:
			track2Ended = true
	# Track 3
	if noteData.track3.is_empty():
		track3Ended = true;
	elif timeStamp >= noteData.track3[track3NextNoteIndex]["Pos"] * 1000 + okTiming:
		#miss.emit(GE.inputEnum.TRACK3, track3NextNoteIndex)
		if track3NextNoteIndex + 1 < noteData.track3.size():
			track3NextNoteIndex += 1
		else:
			track3Ended = true
	# Track 4
	if noteData.track4.is_empty():
		track4Ended = true;
	elif timeStamp > noteData.track4[track4NextNoteIndex]["Pos"] * 1000 + okTiming:
		miss.emit(GE.inputEnum.TRACK4, track4NextNoteIndex)
		if track4NextNoteIndex + 1 < noteData.track4.size():
			track4NextNoteIndex += 1
		else:
			track4Ended = true

# The main judgement logic will be done here.
func judge(inputTime:float, inputIndex: int, input: bool, nextNoteIndex: int, track: Array) -> void:
	
	var isLate: bool
	
	if track.is_empty():
		return
	
	if nextNoteIndex == track.size() - 1:
		return
	
	var nextNotePosition = track[nextNoteIndex]["Pos"] * 1000 #Multiplied by 1000 to convert from sec - ms
	
	var offset: float = inputTime - nextNotePosition
	
	#############################################
	# Checks to see if the note was hit early or
	# Late
	#############################################
	
	if inputTime - nextNotePosition > 0:
		isLate = true
	
	if !input:
		return
	
	if abs(inputTime - nextNotePosition) <= perfectTiming:
		perfect.emit(offset, track, nextNoteIndex)	
		nextNoteIndex += 1
	
	elif abs(inputTime - nextNotePosition) <= almostPerfectTiming:
		if isLate:
			perfectLate.emit(offset, track, nextNoteIndex)
		else:
			perfectEarly.emit(offset, track, nextNoteIndex)
		nextNoteIndex += 1
		
	elif abs(inputTime - nextNotePosition) <= goodTiming:
		if isLate:
			goodLate.emit(offset, track, nextNoteIndex)
		else:
			goodEarly.emit(offset, track, nextNoteIndex)
		nextNoteIndex += 1
	
	elif abs(inputTime - nextNotePosition) <= okTiming:
		if isLate:
			okLate.emit(offset, track, nextNoteIndex)
		else:
			okEarly.emit(offset, track, nextNoteIndex)
		nextNoteIndex += 1

func _onChartCreation(chart):
	noteData = chart.notes


# Signal functions from input component
func _onBTN_1(inputTime, isDown):
	BTN_1 = isDown
	judge(inputTime, GE.inputEnum.TRACK1, BTN_1, track1NextNoteIndex, noteData.track1)


func _onBTN_2(inputTime, isDown):
	BTN_2 = isDown
	judge(inputTime, GE.inputEnum.TRACK2, BTN_2, track2NextNoteIndex, noteData.track2)

func _onBTN_3(inputTime, isDown):
	BTN_3 = isDown
	judge(inputTime, GE.inputEnum.TRACK3, BTN_3, track3NextNoteIndex, noteData.track3)


func _onBTN_4(inputTime, isDown):
	BTN_4 = isDown
	judge(inputTime, GE.inputEnum.TRACK4, BTN_4, track4NextNoteIndex, noteData.track4)


func _onBTN_FX(inputTime, isDown):
	BTN_FX = isDown
	#judge(GE.inputEnum.TRACK1, BTN_FX, trackFXNextNoteIndex, noteData.trackFX)
