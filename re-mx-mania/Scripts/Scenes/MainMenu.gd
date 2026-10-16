extends Control

@export var songSelectButton : Button
@export var settingsButton : Button
@export var storyButton : Button
@export var quitButton : Button
@export var versionLabel : Label

func _ready() -> void:
	GlobalStates.installDefaultCharts()
	songSelectButton.pressed.connect(_onSongSelect)
	settingsButton.pressed.connect(_onSettings)
	storyButton.pressed.connect(_onStory)
	quitButton.pressed.connect(_onQuit)
	versionLabel.text = "Pre-Alpha Version: " + str(GlobalStates.VERSION)

func _onSongSelect():
	SceneManager.loadSongSelect()

func _onSettings():
	SceneManager.loadSettingsMenu()

func _onStory():
	SceneManager.loadStory()

func _onQuit():
	SceneManager.quit()
