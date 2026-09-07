extends Control

@export var songSelectButton : Button
@export var settingsButton : Button
@export var quitButton : Button

## A simple function that takes the chart files from the .pck file,
## and creates a default Charts directory in the user folder on first
## launch.
func installDefaultCharts():
	# If the marker file exists, return from the function
	if FileAccess.file_exists(GlobalStates.CHARTS_DEST + "/.defaultChartsInstalled"):
		return 
	
	copyDirRecursive(GlobalStates.DEFAULT_CHART_SOURCE, GlobalStates.CHARTS_DEST)
	
	var marker = FileAccess.open(GlobalStates.CHARTS_DEST + "/.defaultChartsInstalled", FileAccess.WRITE)
	marker.close()

## A helper function that goes through a directory and copies 
## all of the contents of said directory to another.
func copyDirRecursive(from : String, to : String):
	DirAccess.make_dir_recursive_absolute(to)
	var dir = DirAccess.open(from)
	dir.list_dir_begin()
	var itemName = dir.get_next()
	while itemName != "":
		if itemName.begins_with("."):
			itemName = dir.get_next()
			continue
		var fromPath = from + "/" + itemName
		var toPath = to + "/" + itemName
		if dir.current_is_dir():
			copyDirRecursive(fromPath, toPath)
		else:
			DirAccess.copy_absolute(fromPath, toPath)
		itemName = dir.get_next()
	dir.list_dir_end()

func _ready() -> void:
	installDefaultCharts()
	songSelectButton.pressed.connect(_onSongSelect)
	settingsButton.pressed.connect(_onSettings)
	quitButton.pressed.connect(_onQuit)

func _onSongSelect():
	SceneManager.loadSongSelect()

func _onSettings():
	SceneManager.loadSettingsMenu()

func _onQuit():
	SceneManager.quit()
