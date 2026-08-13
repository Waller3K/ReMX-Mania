extends Node

##################################################
# This autoload script will be used to swap
# between scenes in the game with various
# transistions and will handle passing 
# info inbetween scenes and the GlobalStates
# auto load!
##################################################

## Switches to Chart Player screen with the given chart, background info, and more.
func loadChartPlayer(chartPath: String) -> void:
	GlobalStates.currentChartPath = chartPath
	get_tree().change_scene_to_file("res://Scenes/ChartPlayer.tscn")
