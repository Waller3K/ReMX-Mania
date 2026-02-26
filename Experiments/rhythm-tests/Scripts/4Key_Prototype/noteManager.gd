extends Node

###############################
# This node will be used to
# spawn and manage note objects.
###############################

var noteData: Dictionary
var spawningOffset: float = 1.0
var scrollSpd: float
var notes: Array

var noteScene = preload("res://Scenes/Game_Objects/Note.tscn")

func _onChartCreation(chart: Chart) -> void:
	noteData = chart.notes
	
	# Preload the first bit of the map
	for i in range(noteData.track1.size()):
		var newNote = noteScene.instantiate()
		newNote.INIT(noteData.track1[i]["Pos"], spawningOffset, Vector2i(floori(get_window().size.x/2 - 150 * 2), -100), $"../JudgementLine".position)
		$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		add_child(newNote)
	
	for i in range(noteData.track2.size()):
		var newNote = noteScene.instantiate()
		newNote.INIT(noteData.track2[i]["Pos"], spawningOffset, Vector2i(floori(get_window().size.x/2 - 150), -100), $"../JudgementLine".position)
		$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		add_child(newNote)
	
	for i in range(noteData.track3.size()):
		var newNote = noteScene.instantiate()
		newNote.INIT(noteData.track3[i]["Pos"], spawningOffset, Vector2i(floori(get_window().size.x/2 + 150), -100), $"../JudgementLine".position)
		$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		add_child(newNote)
	
	for i in range(noteData.track4.size()):
		var newNote = noteScene.instantiate()
		newNote.INIT(noteData.track4[i]["Pos"], spawningOffset, Vector2i(floori(get_window().size.x/2 + 150 * 2), -100), $"../JudgementLine".position)
		$"../AudioStreamPlayer".connect("songUpdate", newNote._onSongUpdate)
		add_child(newNote)
