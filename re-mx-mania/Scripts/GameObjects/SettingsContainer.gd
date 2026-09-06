extends VBoxContainer

@export var musicSlider : HSlider

@export var sfxSlider : HSlider

@export var offsetBox : SpinBox

@export var scrollSpeedBox : SpinBox

@export var returnButton : Button

@export var actionList : VBoxContainer

@export var pathList : VBoxContainer

@export var debugModeToggle : CheckButton

@export var DirectoriesHeader : HBoxContainer

@export var openDirFD : FileDialog

@onready var InputButtonScene = preload("res://Scenes/GameObjects/InputButton.tscn")

@onready var ChartPathEditScene = preload("res://Scenes/GameObjects/chartPathEdit.tscn")

## Are we currently remapping a keybind?
var isRemapping = false

## What is the action we are trying to rebind?
var actionToRemap = null

## What button is doing the rebinding?
var remappingButton = null

## A Dictionary containing all of the remappable actions and their
## properly formatted names
var actionDict : Dictionary = {
	"BTN 1" : "Button A",
	"BTN 2" : "Button B",
	"BTN 3" : "Button C",
	"BTN 4" : "Button D",
	"BTN FX" : "FX Button",
	"BTN SCRATCH" : "Scratch Button"
}

func _ready():
	# Initializing box values
	musicSlider.value = db_to_linear(GlobalStates.musicVolumeDB)
	sfxSlider.value = db_to_linear(GlobalStates.sfxVolumeDB)
	scrollSpeedBox.value = GlobalStates.scrollSpd
	offsetBox.value = GlobalStates.globalOffset
	debugModeToggle.button_pressed = GlobalStates.isDebug
	initDirHeader()
	createActionList()
	refreshPathList()
	
	# Connecting signals
	musicSlider.value_changed.connect(_onVolumeChange.bind(0))
	sfxSlider.value_changed.connect(_onVolumeChange.bind(1))
	returnButton.pressed.connect(_onReturn)
	scrollSpeedBox.value_changed.connect(_onScrollSpeedChange)
	offsetBox.value_changed.connect(_onOffsetChange)
	debugModeToggle.pressed.connect(_onDebugToggle)


func initDirHeader():
	var AddDirButton : Button = DirectoriesHeader.find_child("AddDirButton")
	
	AddDirButton.pressed.connect(_onAddDirButtonPressed)

## Creates an a list of action remap buttons from the actions in the actionDict
func createActionList():
	InputMap.load_from_project_settings()
	
	# Clears the actionList
	for item in actionList.get_children():
		item.queue_free()
	
	for action in actionDict:
		var button = InputButtonScene.instantiate()
		var actionLabel = button.find_child("ActionLabel")
		var inputLabel = button.find_child("InputLabel")
		
		actionLabel.text = actionDict[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			inputLabel.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			inputLabel.text = ""
		
		actionList.add_child(button)
		button.pressed.connect(_onInputButtonPressed.bind(button, action))

## Updates the button text of the given button to the given event's name
func updateActionList(button, event):
	button.find_child("InputLabel").text = event.as_text().trim_suffix(" (Physical)")

func refreshPathList():
	# Clears the list of paths
	for item in pathList.get_children():
		item.queue_free()
	
	var itemIndex : int = 0
	for path in GlobalStates.chartDirectories:
		addPathItem(itemIndex, path)
		itemIndex += 1

## Called when a path textbox is manually edited!
func _onPathTextChange(newPath : String, itemIndex : int):
	GlobalStates.chartDirectories[itemIndex] = newPath

func removePathItem(itemIndex : int):
	GlobalStates.chartDirectories.remove_at(itemIndex)
	# Refresh the path list
	refreshPathList()

## Takes in an index and the item's path and creates a new path item as a child of the pathList node
func addPathItem(itemIndex : int, path : String):
	var pathEdit = ChartPathEditScene.instantiate()
	var lineEdit : LineEdit = pathEdit.find_child("LineEdit")
	var changeButton : Button = pathEdit.find_child("ChangeButton")
	var deleteButton : Button = pathEdit.find_child("DeleteButton")
	
	lineEdit.text = path
	lineEdit.text_submitted.connect(_onPathTextChange.bind(itemIndex))
	
	changeButton.pressed.connect(_onChangeButtonPressed.bind(itemIndex))
	deleteButton.pressed.connect(removePathItem.bind(itemIndex))
	
	pathList.add_child(pathEdit)

func _onChangeButtonPressed(itemIndex : int):
	openDirFD.visible = true
	var newPath : String = await openDirFD.dir_selected
	GlobalStates.chartDirectories[itemIndex] = newPath
	refreshPathList()

func _onAddDirButtonPressed():
	openDirFD.visible = true
	var newPath : String = await openDirFD.dir_selected
	GlobalStates.chartDirectories.push_back(newPath)
	refreshPathList() 

func _onInputButtonPressed(button, action):
	if !isRemapping:
		isRemapping = true
		actionToRemap = action
		remappingButton = button
		button.find_child("InputLabel").text = "Press any key to rebind!"

func _input(event: InputEvent) -> void:
	if (isRemapping && 
		(event is InputEventKey || 
		(event is InputEventMouseButton && event.pressed)
		)
	):
		# TODO: Fix this so that it doesn't overwrite the alt action!
		# The following line will erase BOTH events and replace it with
		# just one!
		InputMap.action_erase_events(actionToRemap)
		InputMap.action_add_event(actionToRemap, event)
		updateActionList(remappingButton, event)
		
		isRemapping = false
		actionToRemap = null
		remappingButton = null
		
		accept_event()
		

func _onDebugToggle():
	GlobalStates.isDebug = !GlobalStates.isDebug

func _onOffsetChange(newOffset: float):
	GlobalStates.globalOffset = newOffset

func _onScrollSpeedChange(speed: float):
	GlobalStates.scrollSpd = speed

func _onVolumeChange(volume: float, index : int):
	match index:
		0:
			GlobalStates.musicVolumeDB = linear_to_db(volume)
		1:
			GlobalStates.sfxVolumeDB = linear_to_db(volume)

func _onReturn():
	SceneManager.loadMainMenu()
