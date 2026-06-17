extends Control


func _onTestChartButtonPressed():
	GlobalStates.currentChartPath = "res://Charts/Sink to a deep test world - Waller3K/Easy.json"
	get_tree().change_scene_to_file("res://Scenes/Prototype_Build/4Key_Prototype.tscn")


func _onTestChartButton2Pressed() -> void:
	GlobalStates.currentChartPath = "res://Charts/Sink to a deep test world - Waller3K/Medium.json"
	get_tree().change_scene_to_file("res://Scenes/Prototype_Build/4Key_Prototype.tscn")


func _onMainMenuButtonPressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Prototype_Build/Main_Menu.tscn")


func _onTestChartButton3Pressed() -> void:
	GlobalStates.currentChartPath = "res://Charts/Sink to a deep test world - Waller3K/Beginner.json"
	get_tree().change_scene_to_file("res://Scenes/Prototype_Build/4Key_Prototype.tscn")
