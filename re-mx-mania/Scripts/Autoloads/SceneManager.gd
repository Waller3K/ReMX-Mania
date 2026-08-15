extends Node

##################################################
# This autoload script will be used to swap
# between scenes in the game with various
# transistions and will handle passing 
# info inbetween scenes and the GlobalStates
# auto load!
##################################################

## Switches to Chart Player screen with the given chart, background info, and more.
func loadChartPlayer(chartData: Chart) -> void:
	GlobalStates.currentChartData = chartData
	get_tree().change_scene_to_file("res://Scenes/ChartPlayer.tscn")

## Switches from the chart player to the results screen takes in the current chart's results
func loadResultsScreen(chartResults : Results) -> void:
	GlobalStates.currentResults = chartResults
	get_tree().change_scene_to_file("res://Scenes/Results.tscn")

func loadSongSelect():
	get_tree().change_scene_to_file("res://Scenes/SongSelect.tscn")
