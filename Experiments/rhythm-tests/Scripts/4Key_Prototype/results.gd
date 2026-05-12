extends Control

@export var SongTitleText : Label
@export var DifficultyText : Label
@export var FinalScoreText : Label
@export var MaxComboText : Label

func _ready() -> void:
	SongTitleText.text = GlobalStates.currentChartMetadata["Title"]
	DifficultyText.text = GlobalStates.currentChartMetadata["DifficultyName"]
	FinalScoreText.text = "Final Score: " + str(GlobalStates.currentScore)
	MaxComboText.text = "Max Combo:  " + str(GlobalStates.maxCombo)


func _onReturnButtonPressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Prototype_Build/Song_Select.tscn")
