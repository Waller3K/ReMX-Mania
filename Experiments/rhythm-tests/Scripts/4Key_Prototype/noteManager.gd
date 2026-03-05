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

var noteScene = preload("res://Scenes/Game_Objects/Note.tscn")

func _onChartCreation(chart: Chart) -> void:
	noteData = chart.notes
	
	# Preload the first bit of the map
	for i in range(noteData.track1.size()):
		var newNote = noteScene.instantiate()
		newNote.INIT(0, i, noteData.track1[i]["Pos"], spawningOffset, Vector2i(floori(get_window().size.x/2 - 150 * 2), -100), $"../JudgementLine".position)
		$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		add_child(newNote)
		notes.track1.append(newNote)
	
	for i in range(noteData.track2.size()):
		var newNote = noteScene.instantiate()
		newNote.INIT(1, i, noteData.track2[i]["Pos"], spawningOffset, Vector2i(floori(get_window().size.x/2 - 150), -100), $"../JudgementLine".position)
		$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		add_child(newNote)
		notes.track2.append(newNote)
	
	for i in range(noteData.track3.size()):
		var newNote = noteScene.instantiate()
		newNote.INIT(2, i, noteData.track3[i]["Pos"], spawningOffset, Vector2i(floori(get_window().size.x/2 + 150), -100), $"../JudgementLine".position)
		$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		add_child(newNote)
		notes.track3.append(newNote)
	
	for i in range(noteData.track4.size()):
		var newNote = noteScene.instantiate()
		newNote.INIT(3, i, noteData.track4[i]["Pos"], spawningOffset, Vector2i(floori(get_window().size.x/2 + 150 * 2), -100), $"../JudgementLine".position)
		$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		add_child(newNote)
		notes.track4.append(newNote)

func _onNoteHit(track, note):
	match track:
		0:
			if notes.track1.get(note) != null:
				notes.track1.get(note).queue_free()
				notes.track1[note] = null
		1:
			if notes.track2.get(note) != null:
				notes.track2.get(note).queue_free()
				notes.track2[note] = null
		2:
			if notes.track3.get(note) != null:
				notes.track3.get(note).queue_free()
				notes.track3[note] = null
		3:
			if notes.track4.get(note) != null:
				notes.track4.get(note).queue_free()
				notes.track4[note] = null
