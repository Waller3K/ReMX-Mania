extends Control


func _onTestChartButtonPressed():
	GlobalStates.currentChartPath = "res://Assets/Charts/4_Key_Charts/Sink_to_a_deep_Sea_World-Easy.json"
	get_tree().change_scene_to_file("res://Scenes/Prototype_Build/4Key_Prototype.tscn")


func _onTestChartButton2Pressed() -> void:
	GlobalStates.currentChartPath = "res://Assets/Charts/4_Key_Charts/Sink_to_a_deep_Sea_World-Medium.json"
	get_tree().change_scene_to_file("res://Scenes/Prototype_Build/4Key_Prototype.tscn")


func _onMainMenuButtonPressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Prototype_Build/Main_Menu.tscn")
