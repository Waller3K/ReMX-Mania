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

signal scratchHit(judgement : int, offset : float, noteIndex: int, subnoteIndex: int)
signal scratchBreak(noteIndex: int, subnoteIndex: int)

signal debugInfo(trackArray: Array[TrackState])

var songPos: float
var beatLength: float

var tracks: Array[TrackState] = []

# The next subnote's index (Scratch Track ONLY)
var nextSubnoteIndex : int = -1

var chartDone: bool = false 

var notes

var mouseYVel : float = 0.0

var trackCount : int 

func _onSongUpdate(songPosition: float) -> void:
	songPos = songPosition * 1000
	updateNextNote(songPos)
	updateNextSubnote(songPos)
	debugInfo.emit(tracks)

func updateNextNote(songPosition: float) -> void:
	var trackID : int = 0
	for track in tracks:
		# If the track has already ended
		if track.ended:
			pass
			
		elif track.nextNoteIndex > notes[trackID].size() - 1: # If the index is OOB
			track.ended = true
		elif "End" in notes[trackID][track.nextNoteIndex]:
			if songPosition > notes[trackID][track.nextNoteIndex]["End"] * 1000 + GlobalStates.okTiming: # If the note tail is missed:
				var noteData = notes[trackID][track.nextNoteIndex]
				var FX = noteData["Effect"] if "Effect" in noteData else -1
				holdBroken.emit(trackID, track.nextNoteIndex, FX)
				track.noteHeadMissed = false # Reset note head state
				track.isActive = false
				
				# Remember to reset the nextSubnoteIndex!
				if trackID == GlobalEnums.trackIDs.SCRATCH_TRACK:
					nextSubnoteIndex = -1
				
				if track.nextNoteIndex + 1 < notes[trackID].size():
					track.nextNoteIndex += 1
				else:
					track.ended = true
			elif songPosition > notes[trackID][track.nextNoteIndex]["Pos"] * 1000 + GlobalStates.okTiming and !track.isActive:
				# Missing the head of the note doesn't miss the whole hold
				if !track.noteHeadMissed:
					miss.emit(trackID, track.nextNoteIndex)
					track.noteHeadMissed = true
				
		elif songPosition > notes[trackID][track.nextNoteIndex]["Pos"] * 1000 + GlobalStates.okTiming:
			miss.emit(trackID, track.nextNoteIndex)
			if track.nextNoteIndex + 1 < notes[trackID].size():
				track.nextNoteIndex += 1
			else:
				track.ended = true
		trackID += 1

func updateNextSubnote(songPosition: float) -> void:
	if nextSubnoteIndex < 0 or nextSubnoteIndex == -2:
		return
	elif tracks[GlobalEnums.trackIDs.SCRATCH_TRACK].ended == true:
		return
		
	var currentNote = notes[GlobalEnums.trackIDs.SCRATCH_TRACK][tracks[GlobalEnums.trackIDs.SCRATCH_TRACK].nextNoteIndex]
	var currentSubnote = currentNote["Subnotes"][nextSubnoteIndex]
	var notePos = currentSubnote["Pos"]
	if songPosition > notePos * 1000 + GlobalStates.okTiming:
		scratchNoteMiss(currentNote)
		
		if nextSubnoteIndex + 1 < currentNote["Subnotes"].size() - 1:
			nextSubnoteIndex += 1
		else:
			nextSubnoteIndex = -1

## Takes in the input time, the index of the input and the state (true or false)
## of the input and returns a judgement intager based on the track's next note.
func judge(inputTime: float, inputIndex: int, input: bool) -> int:
	var track := tracks[inputIndex]
	var currentNote: Dictionary
	var judgement: int
	var offset: float
	var FX: int
	
	if track.ended == true:
		return track.nextNoteIndex
	
	# Checks if the current index is out of bounds
	if track.nextNoteIndex > notes[inputIndex].size():
		track.ended = true
		return track.nextNoteIndex
	
	if notes[inputIndex].is_empty():
		return track.nextNoteIndex
	else:
		# Loads the note into memory
		currentNote = notes[inputIndex][track.nextNoteIndex]
		FX = currentNote["Effect"] if "Effect" in currentNote else -1 
	
	var nextNotePos = currentNote["Pos"] * 1000 # Multiplied by 1000 to convert from sec - ms
	
	var isHold = "End" in currentNote
	
	# Checks if this is the last note in the track
	if track.nextNoteIndex == notes[inputIndex].size() and !isHold:
		track.ended = true
	
	# Hold Tail Judgement Section
	if input == false:
		# Checks if there is a tail to judge for
		if isHold:
			
			if !track.isActive:
				return track.nextNoteIndex   # already resolved elsewhere
			
			var tailPosition = currentNote["End"] * 1000
			offset = inputTime - tailPosition
			judgement = inputReconciler(inputTime, tailPosition)
			
			if inputIndex == GlobalEnums.trackIDs.SCRATCH_TRACK:
				if nextSubnoteIndex != -1:
					nextSubnoteIndex = -1
		else:
			return track.nextNoteIndex
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
			return track.nextNoteIndex
		
	
	if judgement == GlobalEnums.judgementEnum.MISS:
		miss.emit(inputIndex, track.nextNoteIndex)
	else:
		noteHit.emit(judgement, offset, inputIndex, track.nextNoteIndex)
	
	# Hold Note Tail Specific Logic
	if isHold and input == false:
		if judgement != GlobalEnums.judgementEnum.MISS:
			holdEnded.emit(inputIndex, track.nextNoteIndex, FX)
		else:
			holdBroken.emit(inputIndex, track.nextNoteIndex, FX)
		
		track.isActive = false
		
		if track.nextNoteIndex == notes[inputIndex].size():
			track.ended = true
		
		return track.nextNoteIndex if track.ended else track.nextNoteIndex + 1
	
	# Hold Note Head Specific Logic
	if isHold:
		holdStarted.emit(inputIndex, track.nextNoteIndex, FX)
		track.isActive = true
		return track.nextNoteIndex
	
	# Tapped Note Specific Logic
	if judgement != GlobalEnums.judgementEnum.MISS and track.ended:
		track.lastNoteHit = true
	
	return track.nextNoteIndex if track.ended else track.nextNoteIndex + 1

func scratchJudge(inputTime: float, YDirection: int, _isMoving: bool) -> void:
	var scratchTrack = tracks[GlobalEnums.trackIDs.SCRATCH_TRACK]
	if scratchTrack.ended == true:
		return
	
	var currentNote = notes[GlobalEnums.trackIDs.SCRATCH_TRACK][scratchTrack.nextNoteIndex]
	
	if !"Subnotes" in currentNote:
		print("Invalid ScratchNote")
		return
		
	if nextSubnoteIndex == -1:
		nextSubnoteIndex = 0
	elif nextSubnoteIndex == -2:
		return
	
	var currentSubnote = currentNote["Subnotes"][nextSubnoteIndex]
	
	# Is this a held scratch or a quick scratch
	if "End" in currentSubnote:
		pass
	else:
		var notePos = currentSubnote["Pos"] * 1000
		
		# If the input is earlier than the miss window
		if inputTime < notePos - GlobalStates.okTiming * 1.5:
			return
		
		var judgement : int = inputReconciler(inputTime, notePos)
		
		var offset = inputTime - notePos
		
		print(YDirection)
		
		match int(currentSubnote["Type"]):
			GlobalEnums.scratchEnum.DOWN:
				if YDirection == 1:
					@warning_ignore("standalone_ternary")
					scratchNoteHit(judgement, offset, currentNote) if judgement != GlobalEnums.judgementEnum.MISS else scratchNoteMiss(currentNote)
				else:
					scratchNoteMiss(currentNote)
			GlobalEnums.scratchEnum.COMBINATION:
				if YDirection != 0:
					@warning_ignore("standalone_ternary")
					scratchNoteHit(judgement, offset, currentNote) if judgement != GlobalEnums.judgementEnum.MISS else scratchNoteMiss(currentNote)
				else:
					scratchNoteMiss(currentNote)
			GlobalEnums.scratchEnum.UP:
				if YDirection == -1:
					@warning_ignore("standalone_ternary")
					scratchNoteHit(judgement, offset, currentNote) if judgement != GlobalEnums.judgementEnum.MISS else scratchNoteMiss(currentNote)
				else:
					scratchNoteMiss(currentNote)
			_:
				print("Invalid Scratch Type!" + str(currentSubnote["Type"]))
				

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
func scratchNoteHit(judgement : int, offset : float, currentNote : Dictionary) -> void:
	scratchHit.emit(
			judgement,
		 	offset,
			tracks[GlobalEnums.trackIDs.SCRATCH_TRACK].nextNoteIndex,
			nextSubnoteIndex
			)
	if nextSubnoteIndex + 1 > currentNote["Subnotes"].size() - 1:
		# Set to -2 to show that we have hit the last subnote
		nextSubnoteIndex = -2
	else:
		nextSubnoteIndex += 1

func scratchNoteMiss(currentNote : Dictionary) -> void:
	scratchBreak.emit(tracks[GlobalEnums.trackIDs.SCRATCH_TRACK].nextNoteIndex, nextSubnoteIndex)
	if nextSubnoteIndex + 1 > currentNote["Subnotes"].size() - 1:
		# Set to -2 to show that we have hit the last subnote
		nextSubnoteIndex = -2
	else:
		nextSubnoteIndex += 1

func _onChartCreated(chart: Chart) -> void:
	notes = chart.notes
	
	beatLength = 60.0/chart.bpm
	
	@warning_ignore("unused_variable")
	var Index : int = 0
	for track in range(chart.trackCount + 2):
		var newTrack := TrackState.new()
		tracks.append(newTrack)
		Index += 1
	
	trackCount = chart.trackCount

func _onBTN_1(inputTimestamp: float, isDown: bool) -> void:
	tracks[GlobalEnums.trackIDs.TRACK1].nextNoteIndex = judge(
		inputTimestamp, 
		GlobalEnums.trackIDs.TRACK1,
		isDown
		)

func _onBTN_2(inputTimestamp: float, isDown: bool) -> void:
	tracks[GlobalEnums.trackIDs.TRACK2].nextNoteIndex = judge(
		inputTimestamp, 
		GlobalEnums.trackIDs.TRACK2,
		isDown
		)

func _onBTN_3(inputTimestamp: float, isDown: bool) -> void:
	if trackCount > 2:
		tracks[GlobalEnums.trackIDs.TRACK3].nextNoteIndex = judge(
			inputTimestamp, 
			GlobalEnums.trackIDs.TRACK3,
			isDown
			)

func _onBTN_4(inputTimestamp: float, isDown: bool) -> void:
	if trackCount > 3:
		tracks[GlobalEnums.trackIDs.TRACK4].nextNoteIndex = judge(
			inputTimestamp, 
			GlobalEnums.trackIDs.TRACK4,
			isDown
			)

func _onBTN_FX(inputTimestamp: float, isDown: bool) -> void:
	tracks[GlobalEnums.trackIDs.TRACKFX].nextNoteIndex = judge(
		inputTimestamp, 
		GlobalEnums.trackIDs.TRACKFX,
		isDown
		)

func _onScratchBTN(inputTimestamp: float, isDown: bool) -> void:
	tracks[GlobalEnums.trackIDs.SCRATCH_TRACK].nextNoteIndex = judge(
		inputTimestamp, 
		GlobalEnums.trackIDs.SCRATCH_TRACK,
		isDown
		)


func _onMouseMoved(_inputTimestamp: float, YVelocity: float) -> void:
	mouseYVel = YVelocity


func _onMouseMoving(inputTimestamp: float, isMoving: bool, YDirection: int) -> void:
	if tracks[GlobalEnums.trackIDs.SCRATCH_TRACK].isActive:
		scratchJudge(inputTimestamp, YDirection, isMoving)
