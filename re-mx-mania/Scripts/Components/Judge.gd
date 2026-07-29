extends Node

#############################################
# These signals would both show the final
# judgement of the hit, and also the amount 
# of miliseconds away from either note 
# they are "offset"
#############################################

signal noteHit(judgement : int, offset : float, trackIndex : int, noteIndex : int)
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

var songPos: float

var trackNextNoteIndecies : Array[int]
var trackEndedBools : Array[bool]
var trackActiveBools : Array[bool]
var trackInputStates : Array[bool]
var trackLNHBools : Array[bool]

# The next subnote's index (Scratch Track ONLY)
var nextSubnoteIndex : int = -1

var chartDone: bool = false 

var notes

var mouseYVel : float = 0.0


func _onSongUpdate(songPosition: float) -> void:
	songPos = songPosition * 1000
	updateNextNote(songPos)
	
	

func updateNextNote(songPosition: float) -> void:
	for track in GlobalStates.TRACK_COUNT + 2:
		if trackEndedBools[track]:
			pass
		elif trackNextNoteIndecies[track] > notes[track].size() - 1:
			trackEndedBools[track] = true
		elif notes[track].is_empty():
			trackEndedBools[track] = true
		elif "End" in notes[track][trackNextNoteIndecies[track]]:
			if songPosition > notes[track][trackNextNoteIndecies[track]]["End"] * 1000 + GlobalStates.okTiming:
				miss.emit(track, trackNextNoteIndecies[track])
				if trackNextNoteIndecies[track] + 1 < notes[track].size():
					trackNextNoteIndecies[track] += 1
				else:
					trackEndedBools[track] = true
			elif songPosition > notes[track][trackNextNoteIndecies[track]]["Pos"] * 1000 + GlobalStates.okTiming and !trackActiveBools[track]:
				# Missing the head of the note doesn't miss the whole hold
				miss.emit(track, trackNextNoteIndecies[track])
		elif songPosition > notes[track][trackNextNoteIndecies[track]]["Pos"] * 1000 + GlobalStates.okTiming:
			miss.emit(track, trackNextNoteIndecies[track])
			if trackNextNoteIndecies[track] + 1 < notes[track].size():
				trackNextNoteIndecies[track] += 1
			else:
				trackEndedBools[track] = true

func judge(inputTime: float, inputIndex: int, input: bool) -> int:
	var nextNoteIndex: int = trackNextNoteIndecies[inputIndex]
	var currentNote: Dictionary
	var trackEnded: bool = false
	var judgement: int
	var offset: float
	var FX: int
	
	# Checks if the current index is out of bounds
	if trackNextNoteIndecies[inputIndex] > notes[inputIndex].size() - 1:
		trackEndedBools[inputIndex] = true
		return nextNoteIndex
	
	if notes[inputIndex].is_empty():
		return nextNoteIndex
	else:
		# Loads the note into memory
		currentNote = notes[inputIndex][trackNextNoteIndecies[inputIndex]]
		FX = currentNote["Effect"] if "Effect" in currentNote else -1 
	
	# Checks if this is the last note in the track
	if nextNoteIndex == notes[inputIndex][trackNextNoteIndecies[inputIndex]].size() - 1:
		trackEnded = true
	
	var nextNotePos = currentNote["Pos"] * 1000 # Multiplied by 1000 to convert from sec - ms
	
	var isHold = "End" in currentNote
	
	
	# Hold Tail Judgement Section
	if input == false:
		# Checks if there is a tail to judge for
		if isHold:
			var tailPosition = currentNote["End"] * 1000
			offset = inputTime - tailPosition
			judgement = inputReconciler(inputTime, tailPosition)
		else:
			return nextNoteIndex
	else:
		# Hold Head / Tap Judgement Section
		# Positive is LATE negative is EARLY
		offset = inputTime - nextNotePos
		judgement = inputReconciler(inputTime, nextNotePos)
	
	# Remove infinite frontend of taps and hold head notes
	if offset < GlobalStates.okTiming * -1.5:
		# Checks if we are inside a really long hold note
		if inputTime > nextNotePos and !input:
			pass
		else:
			return nextNoteIndex
		
	
	if judgement == GlobalEnums.judgementEnum.MISS:
		miss.emit(inputIndex, nextNoteIndex)
	else:
		noteHit.emit(judgement, offset, inputIndex, nextNoteIndex)
	
	# Hold Note Tail Specific Logic
	if isHold and input == false:
		if judgement != GlobalEnums.judgementEnum.MISS:
			holdEnded.emit(inputIndex, nextNoteIndex, FX)
		else:
			holdBroken.emit(inputIndex, nextNoteIndex, FX)
		
		trackActiveBools[inputIndex] = false
		
		if trackEnded:
			trackLNHBools[inputIndex] = true
		
		return nextNoteIndex if trackEnded else nextNoteIndex + 1
	
	# Hold Note Head Specific Logic
	if isHold:
		holdStarted.emit(inputIndex, nextNoteIndex, FX)
		trackActiveBools[inputIndex] = true
		return nextNoteIndex
	
	# Tapped Note Specific Logic
	if judgement != GlobalEnums.judgementEnum.MISS and trackEnded:
		trackLNHBools[inputIndex] = true
	
	return nextNoteIndex if trackEnded else nextNoteIndex + 1

func scratchJudge(inputTime: float, YVelocity: float, isMoving: bool) -> void:
	if trackActiveBools[GlobalEnums.trackIDs.SCRATCH_TRACK] == false:
		return
	var currentNote = notes[GlobalEnums.trackIDs.SCRATCH_TRACK][trackNextNoteIndecies[GlobalEnums.trackIDs.SCRATCH_TRACK]]
	
	if !"Subnotes" in currentNote:
		print("Invalid ScratchNote")
		return
		
	if nextSubnoteIndex == -1:
		nextSubnoteIndex = 0
	
	var currentSubnote = currentNote["Subnotes"][nextSubnoteIndex]
	
	# Is this a held scratch or a quick scratch
	if "End" in currentSubnote:
		pass
	else:
		if !isMoving:
			pass
		var judgement = inputReconciler(inputTime, currentSubnote["Pos"] * 1000)
		var offset = inputTime - currentSubnote["Pos"] * 1000
		match int(currentSubnote["Type"]):
			GlobalEnums.scratchEnum.UP:
				if YVelocity > 0:
					print("UP Scratch Hit!")
					scratchNoteHit(judgement, offset, currentNote)
				else:
					print("UP Scratch Miss")
			GlobalEnums.scratchEnum.DOWN:
				if YVelocity < 0:
					print("DOWN Scratch Hit!")
					scratchNoteHit(judgement, offset, currentNote)
				else:
					print("DOWN Scratch Miss")
			GlobalEnums.scratchEnum.COMBINATION:
				if YVelocity != 0:
					print("COMBINATION Scratch Hit!")
					scratchNoteHit(judgement, offset, currentNote)
				else:
					print("COMBINATION Scratch Miss")
			_:
				push_error(
					"Invalid Scratch Type on Note: " + 
					str(GlobalEnums.trackIDs.SCRATCH_TRACK) + 
					":" + 
					str(trackNextNoteIndecies[GlobalEnums.trackIDs.SCRATCH_TRACK]) +
					":" +
					str(nextSubnoteIndex) +
					" of Type: " +
					str(currentSubnote["Type"])
					)

# Takes in the input time, and the target time, then returns the judgement
func inputReconciler(inputTime: float, targetTime: float) -> int:
	var isLate = inputTime > targetTime

	var timingOffset = abs(targetTime - inputTime)

	if timingOffset <= GlobalStates.perfectTiming:
		return GlobalEnums.judgementEnum.PERFECT
	
	elif timingOffset <= GlobalStates.almostPerfectTiming:
		return GlobalEnums.judgementEnum.PERFECTLATE if isLate else GlobalEnums.judgementEnum.PERFECTEARLY
	
	elif timingOffset <= GlobalStates.goodTiming:
		return GlobalEnums.judgementEnum.GOODLATE if isLate else GlobalEnums.judgementEnum.GOODEARLY
	
	elif timingOffset <= GlobalStates.okTiming:
		return GlobalEnums.judgementEnum.OKLATE if isLate else GlobalEnums.judgementEnum.OKEARLY
	
	else:
		return GlobalEnums.judgementEnum.MISS

# Simple Helper Function for scratch note hit detection
func scratchNoteHit(judgement : int, offset : float, currentNote : Dictionary):
	noteHit.emit(
			judgement,
		 	offset,
			GlobalEnums.trackIDs.SCRATCH_TRACK,
			trackNextNoteIndecies[GlobalEnums.trackIDs.SCRATCH_TRACK]
			)
	if nextSubnoteIndex + 1 > currentNote["Subnotes"].size() - 1:
		# Set to -1 to show that we have hit the last subnote
		nextSubnoteIndex = -1
	else:
		nextSubnoteIndex += 1

func _onChartCreated(chart: Chart) -> void:
	notes = chart.notes
	for track in GlobalStates.TRACK_COUNT + 2:
		trackEndedBools.append(false)
		trackNextNoteIndecies.append(0)
		trackInputStates.append(false)
		trackActiveBools.append(false)
		trackLNHBools.append(false)
	
	

func _onBTN_1(inputTimestamp: float, isDown: bool) -> void:
	trackNextNoteIndecies[GlobalEnums.trackIDs.TRACK1] = judge(
		inputTimestamp, 
		GlobalEnums.trackIDs.TRACK1,
		isDown
		)

func _onBTN_2(inputTimestamp: float, isDown: bool) -> void:
	trackNextNoteIndecies[GlobalEnums.trackIDs.TRACK2] = judge(
		inputTimestamp, 
		GlobalEnums.trackIDs.TRACK2,
		isDown
		)

func _onBTN_3(inputTimestamp: float, isDown: bool) -> void:
	if GlobalStates.TRACK_COUNT > 2:
		trackNextNoteIndecies[GlobalEnums.trackIDs.TRACK3] = judge(
			inputTimestamp, 
			GlobalEnums.trackIDs.TRACK3,
			isDown
			)

func _onBTN_4(inputTimestamp: float, isDown: bool) -> void:
	if GlobalStates.TRACK_COUNT > 3:
		trackNextNoteIndecies[GlobalEnums.trackIDs.TRACK4] = judge(
			inputTimestamp, 
			GlobalEnums.trackIDs.TRACK4,
			isDown
			)

func _onBTN_FX(inputTimestamp: float, isDown: bool) -> void:
	trackNextNoteIndecies[GlobalEnums.trackIDs.TRACKFX] = judge(
		inputTimestamp, 
		GlobalEnums.trackIDs.TRACKFX,
		isDown
		)

func _onScratchBTN(inputTimestamp: float, isDown: bool) -> void:
	trackNextNoteIndecies[GlobalEnums.trackIDs.SCRATCH_TRACK] = judge(
		inputTimestamp, 
		GlobalEnums.trackIDs.SCRATCH_TRACK,
		isDown
		)


func _onMouseMoved(_inputTimestamp: float, YVelocity: float) -> void:
	mouseYVel = YVelocity


func _onMouseMoving(inputTimestamp: float, isMoving: bool) -> void:
	scratchJudge(inputTimestamp, mouseYVel, isMoving)
