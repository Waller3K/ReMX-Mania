extends Node

var travelTime : float # Note Travel Time in Milliseconds

@export var judgementLine 	: MeshInstance3D
@export var noteScene		: PackedScene
@export var mainTrack		: MeshInstance3D

# The indexes of the next notes to be spawned
var spawnIndexs : Array[int]
var trackEndedBools : Array[bool]

var activeNoteCount : int = 0

var chart : Chart

var activeNotes : Dictionary
var inactiveNotes : Array

func _onChartCreated(chartData: Chart) -> void:
	for i in GlobalStates.NOTE_POOL_SIZE:
		var noteNode : Node = noteScene.instantiate()
		noteNode.visible = false
		noteNode.judgementLinePos = judgementLine.position.z
		noteNode.mainTrackLength = mainTrack.mesh.size.x
		inactiveNotes.append(noteNode)
		add_child(noteNode)
	
	chart = chartData
	
	for i in GlobalStates.TRACK_COUNT + 2:
		trackEndedBools.append(false)
		spawnIndexs.append(0)

func spawnNotes(songPos: float):
	var spawnPos = songPos + GlobalStates.PRESONG_TIME
	
	for track in GlobalStates.TRACK_COUNT + 2:
		# Checks if it should try to read the next note
		if trackEndedBools[track] :
			continue
		elif chart.notes[track].is_empty():
			trackEndedBools[track] = true
			continue
		elif spawnIndexs[track] > chart.notes[track].size() - 1:
			trackEndedBools[track] = true
			continue
		
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
			spawnIndexs[track] += 1



func _onSongUpdate(songPosition: float) -> void:
	spawnNotes(songPosition)
	for note in activeNotes.values():
		note.update(songPosition)


func _onNoteHit(judgement: int, offset: float, trackIndex: int, noteIndex: int) -> void:
	var key = Vector2i(trackIndex, noteIndex)
	
	if activeNotes.has(key):
		if activeNotes[key].isHold:
			pass
		else:
			activeNotes[key].deactivate()
			inactiveNotes.push_front(activeNotes[key])
			activeNotes.erase(key)
	else:
		pass


func _onMiss(trackIndex: int, noteIndex: int) -> void:
	var key = Vector2i(trackIndex, noteIndex)
	
	if activeNotes.has(key):
		activeNotes[key].deactivate()
		inactiveNotes.push_front(activeNotes[key])
		activeNotes.erase(key)
	else:
		pass
