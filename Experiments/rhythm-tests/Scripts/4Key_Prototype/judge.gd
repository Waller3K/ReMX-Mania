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

#############################################
# These signals are for held notes. They
# say weather or not the held note was hit,
# ended or broken. As well as giving the
# track and note indexes. These would be
# used along side the normal judgement
# signls
#############################################

signal holdStarted(trackIndex: int, noteIndex: int, FX: int)
signal holdEnded(trackIndex: int, noteIndex: int, FX: int)
signal holdBroken(trackIndex: int, noteIndex: int, FX: int)

var noteData: Dictionary

var songPos: float

#Iterators for each track
var track1NextNoteIndex = 0
var track2NextNoteIndex = 0
var track3NextNoteIndex = 0
var track4NextNoteIndex = 0
var trackFXNextNoteIndex = 0

#Track Ended Booleans
var track1Ended = false
var track2Ended = false
var track3Ended = false
var track4Ended = false
var trackFXEnded = false

#Track Held Booleans
var track1Held = false
var track2Held = false
var track3Held = false
var track4Held = false
var trackFXHeld = false

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
var trackFXLNH = false

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
# tracks, also sends out miss signals
#############################################
func updateNextNote(timeStamp: float) -> void:
	
	# Track 1
	if track1Ended:
		pass
	elif noteData.track1.is_empty():
		track1Ended = true;
	elif "End" in noteData.track1[track1NextNoteIndex]:
		if timeStamp > noteData.track1[track1NextNoteIndex]["End"] * 1000 + okTiming and track1LNH != true:
			miss.emit(GE.inputEnum.TRACK1, track1NextNoteIndex)
			print("Hold Missed!")
			if track1NextNoteIndex + 1 < noteData.track1.size():
				track1NextNoteIndex += 1
			else:
				track1Ended = true
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
	elif "End" in noteData.track2[track2NextNoteIndex]:
		if timeStamp > noteData.track2[track2NextNoteIndex]["End"] * 1000 + okTiming and track2LNH != true:
			miss.emit(GE.inputEnum.TRACK2, track2NextNoteIndex)
			print("Hold Missed!")
			if track2NextNoteIndex + 1 < noteData.track2.size():
				track2NextNoteIndex += 1
			else:
				track2Ended = true
	elif timeStamp > noteData.track2[track2NextNoteIndex]["Pos"] * 1000 + okTiming and track2LNH != true:
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
	elif "End" in noteData.track3[track3NextNoteIndex]:
		if timeStamp > noteData.track3[track3NextNoteIndex]["End"] * 1000 + okTiming and track3LNH != true:
			miss.emit(GE.inputEnum.TRACK3, track3NextNoteIndex)
			print("Hold Missed!")
			if track3NextNoteIndex + 1 < noteData.track3.size():
				track3NextNoteIndex += 1
			else:
				track3Ended = true
	elif timeStamp > noteData.track3[track3NextNoteIndex]["Pos"] * 1000 + okTiming and track3LNH != true:
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
	elif "End" in noteData.track4[track4NextNoteIndex]:
		if timeStamp > noteData.track4[track4NextNoteIndex]["End"] * 1000 + okTiming and track4LNH != true:
			miss.emit(GE.inputEnum.TRACK4, track4NextNoteIndex)
			if track4NextNoteIndex + 1 < noteData.track4.size():
				track4NextNoteIndex += 1
			else:
				track4Ended = true
	elif timeStamp > noteData.track4[track4NextNoteIndex]["Pos"] * 1000 + okTiming and track4LNH != true:
		miss.emit(GE.inputEnum.TRACK4, track4NextNoteIndex)
		if track4NextNoteIndex + 1 < noteData.track4.size():
			track4NextNoteIndex += 1
		else:
			track4Ended = true
	

	# Track FX
	if trackFXEnded:
		pass
	elif noteData.trackFX.is_empty():
		trackFXEnded = true;
	elif "End" in noteData.trackFX[trackFXNextNoteIndex]:
		if timeStamp > noteData.trackFX[trackFXNextNoteIndex]["End"] * 1000 + okTiming and trackFXLNH != true:
			miss.emit(GE.inputEnum.FX_TRACK, trackFXNextNoteIndex)
			if trackFXNextNoteIndex + 1 < noteData.trackFX.size():
				trackFXNextNoteIndex += 1
			else:
				trackFXEnded = true
	elif timeStamp > noteData.trackFX[trackFXNextNoteIndex]["Pos"] * 1000 + okTiming and trackFXLNH != true:
		miss.emit(GE.inputEnum.FX_TRACK, trackFXNextNoteIndex)
		if trackFXNextNoteIndex + 1 < noteData.trackFX.size():
			trackFXNextNoteIndex += 1
		else:
			trackFXEnded = true

####################################################
# The main judgement logic will be done here.
# This function returns the updated nextNoteIndex! 
# This is a workaround due to Godot copying ints by 
# value and not by reference
####################################################

func judge(inputTime:float, inputIndex: int, input: bool, nextNoteIndex: int, track: Array, FX: int = -1) -> int:
	
	var trackEnded: bool = false

	var judgement: int = -1

	var offset: float
	
	# -1 is no effect
	var effect: int = FX

	if track.is_empty():
		return nextNoteIndex
	
	if nextNoteIndex == track.size() - 1:
		trackEnded = true
		
	var nextNotePosition = track[nextNoteIndex]["Pos"] * 1000 # Multiplied by 1000 to convert from sec - ms

	var isHold = "End" in track[nextNoteIndex]
	
	if input == false:
		# Checks if there is a tail to judge for
		if isHold:
			var tailPosition = track[nextNoteIndex]["End"] * 1000
			offset = inputTime - tailPosition
			judgement = inputReconciler(inputTime, tailPosition)
		else:
			return nextNoteIndex

	else:
		# Positive is LATE negative is EARLY
		offset = inputTime - nextNotePosition
		judgement = inputReconciler(inputTime, nextNotePosition)

	# Remove infinite frontend of taps and hold head notes
	if offset < okTiming * -1.5:
		# Checks if we are inside a really long hold note
		if inputTime > nextNotePosition and !input:
			pass
		else:
			return nextNoteIndex
	
	match judgement:
		GE.judgementEnum.PERFECT:
			perfect.emit(offset, inputIndex, nextNoteIndex)
		GE.judgementEnum.PERFECTEARLY:
			perfectEarly.emit(offset, inputIndex, nextNoteIndex)
		GE.judgementEnum.PERFECTLATE:
			perfectLate.emit(offset, inputIndex, nextNoteIndex)
		GE.judgementEnum.GOODEARLY:
			goodEarly.emit(offset, inputIndex, nextNoteIndex)
		GE.judgementEnum.GOODLATE:
			goodLate.emit(offset, inputIndex, nextNoteIndex)
		GE.judgementEnum.OKEARLY:
			okEarly.emit(offset, inputIndex, nextNoteIndex)
		GE.judgementEnum.OKLATE:
			okLate.emit(offset, inputIndex, nextNoteIndex)
		GE.judgementEnum.MISS:
			miss.emit(inputIndex, nextNoteIndex)
	
	####################################################
	# Hold Note Tail Specific Logic
	####################################################

	if isHold and input == false:
		if judgement != GE.judgementEnum.MISS:
			holdEnded.emit(inputIndex, nextNoteIndex, effect)
		else:
			holdBroken.emit(inputIndex, nextNoteIndex, effect)

		match inputIndex:
			GE.inputEnum.TRACK1:
				track1Held = false
			GE.inputEnum.TRACK2:
				track2Held = false
			GE.inputEnum.TRACK3:
				track3Held = false
			GE.inputEnum.TRACK4:
				track4Held = false
			GE.inputEnum.FX_TRACK:
				trackFXHeld = false

		if trackEnded:
			lastNoteHit(inputIndex)
		return nextNoteIndex if trackEnded else nextNoteIndex + 1




	####################################################
	# Hold Note Head Specific Logic
	####################################################

	if isHold:
		holdStarted.emit(inputIndex, nextNoteIndex, effect)
		match inputIndex:
			GE.inputEnum.TRACK1:
				track1Held = true
			GE.inputEnum.TRACK2:
				track2Held = true
			GE.inputEnum.TRACK3:
				track3Held = true
			GE.inputEnum.TRACK4:
				track4Held = true
			GE.inputEnum.FX_TRACK:
				trackFXHeld = true
		# 'nextNoteIndex' not incremented until hold tail
		return nextNoteIndex

	####################################################
	# Tapped Note Specific Logic
	####################################################
	
	if judgement != GE.judgementEnum.MISS and trackEnded:
		lastNoteHit(inputIndex)

	return nextNoteIndex if trackEnded else nextNoteIndex + 1

####################################################
# Takes in the target timestamp and the input
# timestamp, and returns a value from the global
# enum representing its judgement
####################################################
func inputReconciler(inputTime: float, targetTime: float) -> int:
	var isLate = inputTime > targetTime

	var timingOffset = abs(targetTime - inputTime)

	if timingOffset <= perfectTiming:
		return GE.judgementEnum.PERFECT
	
	elif timingOffset <= almostPerfectTiming:
		return GE.judgementEnum.PERFECTLATE if isLate else GE.judgementEnum.PERFECTEARLY
	
	elif timingOffset <= goodTiming:
		return GE.judgementEnum.GOODLATE if isLate else GE.judgementEnum.GOODEARLY
	
	elif timingOffset <= okTiming:
		return GE.judgementEnum.OKLATE if isLate else GE.judgementEnum.OKEARLY
	
	else:
		return GE.judgementEnum.MISS

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
		GE.inputEnum.FX_TRACK:
			trackFXLNH = true

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


func _onBTN_FX(inputTime, isDown):
	BTN_FX = isDown
	trackFXNextNoteIndex = judge(inputTime, GE.inputEnum.FX_TRACK, BTN_FX, trackFXNextNoteIndex, noteData.trackFX, noteData.trackFX[trackFXNextNoteIndex]["Effect"])
