extends Node

###############################
# This node will be used to
# spawn and manage note objects.
###############################

var noteData: Dictionary
var spawningOffset: float = 1.0
var scrollSpd: float
var notes: Dictionary = {
	track1 = [],
	track2 = [],
	track3 = [],
	track4 = [],
	trackFX = []
}

@export var judegementLine : ColorRect

var noteScene = preload("res://Scenes/Game_Objects/Note.tscn")

func _onChartCreation(chart: Chart) -> void:
	noteData = chart.notes
	
	#This line will give us the Track Colorrects in the Tracks HBoxContainer
	var UITracks = judegementLine.get_child(0).get_child(0).get_children();
	
	# Preload the first bit of the map
	# Fixed so that now it renders with the UI elements
	# As a child of the track it is on
	# REMINDER: Because the notes are now children of their tracks
	# Their positions are now RELATIVE to the track!
	for i in range(noteData.track1.size()):
		var newNote = noteScene.instantiate()
		UITracks[0].add_child(newNote)
		newNote.INIT(
			GE.inputEnum.TRACK1, 
			i, 
			noteData.track1[i]["Pos"], 
			spawningOffset, 
			Vector2i(0, -100), 
			Vector2(0, UITracks[0].size.y),
			noteData.track1[i]["End"] if noteData.track1[i].get("End") else -1 
		)
		$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		notes.track1.append(newNote)
	
	for i in range(noteData.track2.size()):
		var newNote = noteScene.instantiate()
		UITracks[1].add_child(newNote)
		newNote.INIT(
			GE.inputEnum.TRACK2, 
			i, 
			noteData.track2[i]["Pos"], 
			spawningOffset, 
			Vector2i(0, -100), 
			Vector2(0, UITracks[1].size.y),
			noteData.track2[i]["End"] if noteData.track2[i].get("End") else -1
		)
		$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		notes.track2.append(newNote)
	
	for i in range(noteData.track3.size()):
		var newNote = noteScene.instantiate()
		UITracks[2].add_child(newNote)
		newNote.INIT(
			GE.inputEnum.TRACK3, 
			i, 
			noteData.track3[i]["Pos"], 
			spawningOffset, 
			Vector2i(0, -100), 
			Vector2(0, UITracks[2].size.y),
			noteData.track3[i]["End"] if noteData.track3[i].get("End") else -1
		)
		$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		notes.track3.append(newNote)
	
	for i in range(noteData.track4.size()):
		var newNote = noteScene.instantiate()
		UITracks[3].add_child(newNote)
		newNote.INIT(
			GE.inputEnum.TRACK4, 
			i, 
			noteData.track4[i]["Pos"], 
			spawningOffset, 
			Vector2i(0, -100), 
			Vector2(0, UITracks[3].size.y),
			noteData.track4[i]["End"] if noteData.track4[i].get("End") else -1
		)
		$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		notes.track4.append(newNote)

func _onNoteHit(track, note):

	match track:
		GE.inputEnum.TRACK1:
			if notes.track1.get(note) != null:
				if(notes.track1.get(note).endTargetTime != -1):
					pass
				else:
					notes.track1.get(note).queue_free()
					notes.track1[note] = null
		GE.inputEnum.TRACK2:
			if notes.track2.get(note) != null:
				if(notes.track2.get(note).endTargetTime != -1):
					pass
				else:
					notes.track2.get(note).queue_free()
					notes.track2[note] = null
		GE.inputEnum.TRACK3:
			if notes.track3.get(note) != null:
				if(notes.track3.get(note).endTargetTime != -1):
					pass
				else:
					notes.track3.get(note).queue_free()
					notes.track3[note] = null
		GE.inputEnum.TRACK4:
			if notes.track4.get(note) != null:
				if(notes.track4.get(note).endTargetTime != -1):
					pass
				else:
					notes.track4.get(note).queue_free()
					notes.track4[note] = null
