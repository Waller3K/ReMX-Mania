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
	songPos = timeStamp
	
	updateNextNote(timeStamp)
	
	#print("Track 1, Note : " + str(track1LastNoteIndex) + " " + str(noteData.track1[track1LastNoteIndex]["beenHit"]));
	
	#############################################
	# If the note is not hit before the end of the
	# note's timing window the funciton emits the
	# miss signal
	# TODO: Clean up this section its kinda ugly
	#############################################
	
	if track1LastNoteIndex < 0:
		if track1NextNoteIndex > 1:
			track1LastNoteIndex+=1
	elif timeStamp > noteData.track1[track1LastNoteIndex]["Pos"] + okTiming/1000 :
		if noteData.track1[track1LastNoteIndex]["beenHit"] == false :
			if not track1Ended:
				miss.emit(GE.inputEnum.TRACK1, track1LastNoteIndex)
		if track1LastNoteIndex != noteData.track1.size() - 1:
			track1LastNoteIndex+=1
	
	if track2LastNoteIndex < 0:
		if track2NextNoteIndex > 1:
			track2LastNoteIndex+=1
	elif timeStamp > noteData.track2[track2LastNoteIndex]["Pos"] + okTiming/1000:
		if noteData.track2[track2LastNoteIndex]["beenHit"] == false :
			if not track2Ended :
				miss.emit(GE.inputEnum.TRACK2, track2LastNoteIndex)
		if track2LastNoteIndex != noteData.track2.size() - 1:
			track2LastNoteIndex+=1
	
	if track3LastNoteIndex < 0:
		if track3NextNoteIndex > 1:
			track3LastNoteIndex+=1
	elif timeStamp > noteData.track3[track3LastNoteIndex]["Pos"] + okTiming/1000:
		if noteData.track3[track3LastNoteIndex]["beenHit"] == false :
			if not track3Ended :
				miss.emit(GE.inputEnum.TRACK3, track3LastNoteIndex)
		if track3LastNoteIndex != noteData.track3.size() - 1:
			track3LastNoteIndex+=1
	
	if track4LastNoteIndex < 0:
		if track4NextNoteIndex > 1:
			track4LastNoteIndex+=1
	elif timeStamp > noteData.track4[track4LastNoteIndex]["Pos"] + okTiming/1000:
		if noteData.track4[track4LastNoteIndex]["beenHit"] == false :
			if not track4Ended :
				miss.emit(GE.inputEnum.TRACK4, track4LastNoteIndex)
		if track4LastNoteIndex != noteData.track4.size() - 1:
			track4LastNoteIndex+=1

#############################################
# Updates the next note index when we pass
# a note and sets the variables for ending the 
# tracks
#############################################
func updateNextNote(timeStamp: float) -> void:
	# Track 1
	if noteData.track1.is_empty():
		track1Ended = true;
	elif timeStamp >= noteData.track1[track1NextNoteIndex]["Pos"]:
		if track1NextNoteIndex + 1 < noteData.track1.size():
			track1NextNoteIndex += 1
			track1LastNoteIndex += 1
		else:
			track1Ended = true
	# Track 2
	if noteData.track2.is_empty():
		track2Ended = true;
	elif timeStamp >= noteData.track2[track2NextNoteIndex]["Pos"]:
		if track2NextNoteIndex + 1 < noteData.track2.size():
			track2NextNoteIndex += 1
			track2LastNoteIndex += 1
		else:
			track2Ended = true
	# Track 3
	if noteData.track3.is_empty():
		track3Ended = true;
	elif timeStamp >= noteData.track3[track3NextNoteIndex]["Pos"]:
		if track3NextNoteIndex + 1 < noteData.track3.size():
			track3NextNoteIndex += 1
			track3LastNoteIndex += 1
		else:
			track3Ended = true
	# Track 4
	if noteData.track4.is_empty():
		track4Ended = true;
	elif timeStamp >= noteData.track4[track4NextNoteIndex]["Pos"]:
		if track4NextNoteIndex + 1 < noteData.track4.size():
			track4NextNoteIndex += 1
			track4LastNoteIndex += 1
		else:
			track4Ended = true

# The main judgement logic will be done here.
func judge(inputIndex: int,input: bool, nextNoteIndex: int, track: Array) -> void:
	
	if track.is_empty():
		return
	
	if nextNoteIndex == track.size() - 1:
		return
	
	#############################################
	# Checks to see if this is an early hit.
	#############################################
	if songPos >= track[nextNoteIndex]["Pos"] - perfectTiming/1000 : #Divided by 1000 to convert from ms to sec	
		if input == true: #If the key is currently being held down
			#############################################
			# This line emits the perfect signal and with
			# it how far off from the next note's 
			# timestamp the input occured
			#############################################
			perfect.emit(songPos - track[nextNoteIndex]["Pos"], inputIndex, nextNoteIndex)
			track[nextNoteIndex]["beenHit"] = true
			nextNoteIndex += 1
	elif songPos >= track[nextNoteIndex]["Pos"] - almostPerfectTiming/1000 :
		if input == true: #If the key is currently being held down
			perfectEarly.emit(songPos - track[nextNoteIndex]["Pos"], inputIndex, nextNoteIndex)
			track[nextNoteIndex]["beenHit"] = true
			nextNoteIndex += 1
	elif songPos >= track[nextNoteIndex]["Pos"] - goodTiming/1000 :
		if input == true: #If the key is currently being held down
			goodEarly.emit(songPos - track[nextNoteIndex]["Pos"], inputIndex, nextNoteIndex)
			track[nextNoteIndex]["beenHit"] = true
			nextNoteIndex += 1
	elif songPos >= track[nextNoteIndex]["Pos"] - okTiming/1000 :
		if input == true: #If the key is currently being held down
			okEarly.emit(songPos - track[nextNoteIndex]["Pos"], inputIndex, nextNoteIndex)
			track[nextNoteIndex]["beenHit"] = true
			nextNoteIndex += 1
	
	#############################################
	# Checks to see if this is a late hit. 
	# Always check this last so it is not 
	# prioritized over an on time hit of a nearby
	# next note!
	#############################################
	if nextNoteIndex - 1 < 0:
		return
	
	var lastNoteIndex = nextNoteIndex - 1
	
	if songPos >= track[lastNoteIndex]["Pos"] + perfectTiming/1000 : #Divided by 1000 to convert from ms to sec	
		if input == true: #If the key is currently being held down
			#############################################
			# This line emits the perfect signal and with
			# it how far off from the last note's 
			# timestamp the input occured
			#############################################
			perfect.emit(songPos - track[lastNoteIndex]["Pos"], inputIndex, nextNoteIndex)
			track[lastNoteIndex]["beenHit"] = true
			lastNoteIndex += 1
	elif songPos >= track[lastNoteIndex]["Pos"] + almostPerfectTiming/1000 :
		if input == true: #If the key is currently being held down
			perfectLate.emit(songPos - track[lastNoteIndex]["Pos"], inputIndex, nextNoteIndex)
			track[lastNoteIndex]["beenHit"] = true
			lastNoteIndex += 1
	elif songPos >= track[lastNoteIndex]["Pos"] + goodTiming/1000 :
		if input == true: #If the key is currently being held down
			goodLate.emit(songPos - track[lastNoteIndex]["Pos"], inputIndex, nextNoteIndex)
			track[lastNoteIndex]["beenHit"] = true
			lastNoteIndex += 1
	elif songPos >= track[lastNoteIndex]["Pos"] + okTiming/1000 :
		if input == true: #If the key is currently being held down
			okLate.emit(songPos - track[lastNoteIndex]["Pos"], inputIndex, nextNoteIndex)
			track[lastNoteIndex]["beenHit"] = true
			lastNoteIndex += 1
	
	
	
	
	

func _onChartCreation(chart):
	noteData = chart.notes


# Signal functions from input component
func _onBTN_1(isDown):
	BTN_1 = isDown
	judge(GE.inputEnum.TRACK1, BTN_1, track1NextNoteIndex, noteData.track1)


func _onBTN_2(isDown):
	BTN_2 = isDown
	judge(GE.inputEnum.TRACK2, BTN_2, track2NextNoteIndex, noteData.track2)

func _onBTN_3(isDown):
	BTN_3 = isDown
	judge(GE.inputEnum.TRACK3, BTN_3, track3NextNoteIndex, noteData.track3)


func _onBTN_4(isDown):
	BTN_4 = isDown
	judge(GE.inputEnum.TRACK4, BTN_4, track4NextNoteIndex, noteData.track4)


func _onBTN_FX(isDown):
	BTN_FX = isDown
	#judge(GE.inputEnum.TRACK1, BTN_FX, trackFXNextNoteIndex, noteData.trackFX)
