extends Node

var travelTime : float # Note Travel Time in Milliseconds

@export var judgementLine 	: MeshInstance3D
@export var noteScene		: PackedScene
@export var subnoteScene	: PackedScene
@export var mainTrack		: MeshInstance3D

# The indexes of the next notes to be spawned
var spawnIndexs : Array[int]

# Index of scratch subnote -1 is the default value for no subnote
var subnoteIndex : int = -1

var trackEndedBools : Array[bool]

var activeNoteCount : int = 0

var activeSubnoteCount : int = 0

var chart : Chart

var activeNotes : Dictionary
var inactiveNotes : Array

var activeSubnotes : Dictionary
var inactiveSubnotes : Array

var songPos : float

func _onChartCreated(chartData: Chart) -> void:
	for i in range(GlobalStates.NOTE_POOL_SIZE):
		var noteNode : Node = noteScene.instantiate()
		noteNode.visible = false
		noteNode.judgementLinePos = judgementLine.position.z
		noteNode.mainTrackLength = mainTrack.mesh.size.x
		inactiveNotes.append(noteNode)
		add_child(noteNode)
		
		var subnoteNode : Node = subnoteScene.instantiate()
		subnoteNode.visible = false
		subnoteNode.judgementLinePos = judgementLine.position.z
		inactiveSubnotes.append(subnoteNode)
		add_child(subnoteNode)
	
	chart = chartData
	
	for i in range(chart.trackCount + 2):
		trackEndedBools.append(false)
		spawnIndexs.append(0)

func spawnNotes(songPos: float):
	var spawnPos = songPos + GlobalStates.PRESONG_TIME
	
	for track in chart.trackCount + 2:
		# Checks if it should try to read the next note
		if trackEndedBools[track] :
			continue
		elif chart.notes[track].is_empty():
			trackEndedBools[track] = true
			continue
		elif spawnIndexs[track] > chart.notes[track].size() - 1:
			trackEndedBools[track] = true
			continue
		
		# Is this a scratch track note?
		if track == GlobalEnums.trackIDs.SCRATCH_TRACK:
			var noteData = chart.notes[track][spawnIndexs[track]]
			if "Subnotes" in noteData:
				pass
		
		if spawnPos > chart.notes[track][spawnIndexs[track]]["Pos"]:
			var newNote = inactiveNotes.pop_back()
			newNote.activate(
				track, 
				spawnIndexs[track], 
				50, 
				chart.notes[track][spawnIndexs[track]]["Pos"],
				chart.notes[track][spawnIndexs[track]]["End"] if chart.notes[track][spawnIndexs[track]].has("End") else -1.0 
				)
			var key = Vector2i(track, spawnIndexs[track])
			activeNotes[key] = newNote
			
			# Is this a scratch track note?
			if track == GlobalEnums.trackIDs.SCRATCH_TRACK:
				var noteData = chart.notes[track][spawnIndexs[track]]
				if "Subnotes" in noteData:
					for subnoteIndex in noteData["Subnotes"].size():
						var newSubnote = inactiveSubnotes.pop_back()
						newSubnote.activate(
							spawnIndexs[track],
							subnoteIndex,
							noteData["Subnotes"][subnoteIndex]["Type"],
							10,
							noteData["Subnotes"][subnoteIndex]["Pos"],
							noteData["Subnotes"][subnoteIndex]["End"] if noteData["Subnotes"][subnoteIndex].has("End") else -1.0
						)
						var subnoteKey = Vector3i(track, spawnIndexs[track], subnoteIndex)
						activeSubnotes[subnoteKey] = newSubnote
			spawnIndexs[track] += 1



func _onSongUpdate(songPosition: float) -> void:
	spawnNotes(songPosition)
	for note in activeNotes.values():
		note.update(songPosition)
	
	for subnote in activeSubnotes.values():
		subnote.update(songPosition)


func _onNoteHit(judgement: int, offset: float, trackIndex: int, noteIndex: int) -> void:
	var key = Vector2i(trackIndex, noteIndex)
	
	if activeNotes.has(key):
		if activeNotes[key].isHold:
			var hitNote = activeNotes[key]
			
			var hitOffset = songPos * 1000 - hitNote.hitTime
			
			var releaseOffset = songPos * 1000 - hitNote.releaseTime
			
			if hitOffset > releaseOffset:
				hitNote.holdHit()
				return
			else:
				activeNotes[key].deactivate()
				inactiveNotes.push_front(activeNotes[key])
				activeNotes.erase(key)
				return
		else:
			activeNotes[key].deactivate()
			inactiveNotes.push_front(activeNotes[key])
			activeNotes.erase(key)
	else:
		return


func _onMiss(trackIndex: int, noteIndex: int) -> void:
	var key = Vector2i(trackIndex, noteIndex)
	
	if activeNotes.has(key):
		
		if activeNotes[key].isHold:
			var missedNote = activeNotes[key]
			
			var hitOffset = songPos * 1000 - missedNote.hitTime
			
			var releaseOffset = songPos * 1000 - missedNote.releaseTime
			
			if hitOffset > releaseOffset:
				missedNote.holdMissed()
				return
			else:
				activeNotes[key].deactivate()
				inactiveNotes.push_front(activeNotes[key])
				activeNotes.erase(key)
				return
		else:
			activeNotes[key].deactivate()
			inactiveNotes.push_front(activeNotes[key])
			activeNotes.erase(key)
	else:
		pass

# Only called when a subnote is missed in the scratch track
func _onScratchBreak(noteIndex: int, subnoteIndex: int) -> void:
	var mainKey := Vector2i(GlobalEnums.trackIDs.SCRATCH_TRACK, noteIndex)
	
	#print("Miss!")
	
	if activeNotes.has(mainKey):
		var missedNote = activeNotes[mainKey]
		
		missedNote.holdMissed()
		
		var subKey := Vector3i(GlobalEnums.trackIDs.SCRATCH_TRACK, noteIndex, subnoteIndex)
		
		if activeSubnotes.has(subKey):
			var missedScratch = activeSubnotes[subKey]
			
			if missedScratch.isHold:
				return
			
			missedScratch.deactivate()
			inactiveSubnotes.push_front(missedScratch)
			activeSubnotes.erase(missedScratch)
			


func _onScratchHit(judgement: int, offset: float, noteIndex: int, subnoteIndex: int) -> void:
	#print("Hit!")
	var mainKey = Vector2i(GlobalEnums.trackIDs.SCRATCH_TRACK, noteIndex)
	
	if activeNotes.has(mainKey):
		var subKey = Vector3i(GlobalEnums.trackIDs.SCRATCH_TRACK, noteIndex, subnoteIndex)
		
		if activeSubnotes.has(subKey):
			var hitNote = activeSubnotes[subKey]
			
			hitNote.deactivate()
			inactiveSubnotes.push_front(hitNote)
			activeSubnotes.erase(hitNote)
## help
