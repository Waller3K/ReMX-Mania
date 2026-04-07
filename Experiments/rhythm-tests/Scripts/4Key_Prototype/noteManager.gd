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
	
	var trackWidth = judegementLine.size.x/4
	
	#This line will give us the Track Colorrects in the Tracks HBoxContainer
	var UITracks = judegementLine.get_child(0).get_child(0).get_children();
	
	# Preload the first bit of the map
	# Fixed so that now it renders with the UI elements
	# As a child of the track it is on
	for i in range(noteData.track1.size()):
		var newNote = noteScene.instantiate()
		newNote.INIT(
			GE.inputEnum.TRACK1, 
			i, 
			noteData.track1[i]["Pos"], 
			spawningOffset, 
			Vector2i(UITracks[0].position.x, -100), 
			Vector2(UITracks[0].position.x, UITracks[0].position.y + UITracks[0].size.y)
		)
		$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		UITracks[0].add_child(newNote)
		notes.track1.append(newNote)
	
	for i in range(noteData.track2.size()):
		var newNote = noteScene.instantiate()
		UITracks[1].add_child(newNote)
		newNote.INIT(
			GE.inputEnum.TRACK2, 
			i, 
			noteData.track2[i]["Pos"], 
			spawningOffset, 
			Vector2i(UITracks[1].position.x, -100), 
			Vector2(UITracks[1].position.x, UITracks[1].position.y + UITracks[1].size.y)
		)
		$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		UITracks[1].add_child(newNote)
		notes.track2.append(newNote)
	
	#for i in range(noteData.track3.size()):
		#var newNote = noteScene.instantiate()
		#var noteXOffset = newNote.texture.get_width()/2
		#newNote.INIT(
			#GE.inputEnum.TRACK3, 
			#i, 
			#noteData.track3[i]["Pos"], 
			#spawningOffset, 
			#Vector2i(judegementLine.position.x + trackWidth * 2 + noteXOffset, -100),  
			#Vector2(judegementLine.position.x, judegementLine.position.y + judegementLine.size.y * 0.5)
		#)
		#$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		#add_child(newNote)
		#notes.track3.append(newNote)
	#
	#for i in range(noteData.track4.size()):
		#var newNote = noteScene.instantiate()
		#var noteXOffset = newNote.texture.get_width()/2
		#newNote.INIT(
			#GE.inputEnum.TRACK4, 
			#i, 
			#noteData.track4[i]["Pos"], 
			#spawningOffset, 
			#Vector2i(judegementLine.position.x + trackWidth * 3 + noteXOffset, -100),  
			#Vector2(judegementLine.position.x, judegementLine.position.y + judegementLine.size.y * 0.5)
		#)
		#$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		#add_child(newNote)
		#notes.track4.append(newNote)

func _onNoteHit(track, note):
	match track:
		GE.inputEnum.TRACK1:
			if notes.track1.get(note) != null:
				notes.track1.get(note).queue_free()
				notes.track1[note] = null
		GE.inputEnum.TRACK2:
			if notes.track2.get(note) != null:
				notes.track2.get(note).queue_free()
				notes.track2[note] = null
		GE.inputEnum.TRACK3:
			if notes.track3.get(note) != null:
				notes.track3.get(note).queue_free()
				notes.track3[note] = null
		GE.inputEnum.TRACK4:
			if notes.track4.get(note) != null:
				notes.track4.get(note).queue_free()
				notes.track4[note] = null
