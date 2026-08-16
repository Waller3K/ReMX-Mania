extends Control

@export var songSelectButton : Button
@export var settingsButton : Button
@export var quitButton : Button

func _ready() -> void:
	songSelectButton.pressed.connect(_onSongSelect)
	settingsButton.pressed.connect(_onSettings)
	quitButton.pressed.connect(_onQuit)

func _onSongSelect():
	SceneManager.loadSongSelect()

func _onSettings():
	SceneManager.loadSettingsMenu()

func _onQuit():
	SceneManager.quit()
