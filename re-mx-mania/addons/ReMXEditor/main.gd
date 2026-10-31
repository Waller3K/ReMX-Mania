@tool
class_name ReMXEditor
extends EditorPlugin

const MAINPANEL = preload("res://addons/ReMXEditor/Scenes/ReMXEditorScene.tscn")

# *******GLOBAL VARIABLES!*******
## The current chartdata that is loaded into memory
static var currentChart : Chart = null

## The DB offset for each of the tracks to avoid clipping
const VOLUME_OFFSET_DB := 10.0

## The current Volume level of the editor
static var editorVolumeDB : float = 0.0

static var globalOffset : float = 0.0

static var defaultFont : Font = preload("res://addons/ReMXEditor/Assets/Fonts/ARIAL.TTF")

## The snap level of the grid in a fraction of the beat!
static var gridSnap : float = 0.25

# CURRENT CHART VARIABLES
## The current song position of the playing chart (In Seconds!)
static var chartPos : float = 0.0

## The length of the currently loaded chart (In Seconds!)
static var chartLength : float = 0.0

## Returns true if the chart is being played in the editor
static var isPlaying : bool = false

## The timestamp (IN SECONDS) that the chart was last paused at.
## Is set to -1.0 if the song hasn't been paused!
static var pausedAt : float = -1.0

var mainPanelInstance : Node

## Helper function that takes in the size of a node, 
## and returns the Y position that represents the current chart's 
## timestamp with 0 being the bottom of the node, and the chart's 
## length being at the top!
static func chartPosToScreenPos(nodeSize : Vector2, posOverride : float = -1.0, isScrolling : bool = false) -> float:
	if isScrolling:
		return remap(posOverride, chartPos, 1.0+chartPos, nodeSize.y, 0.0)
	
	if posOverride != -1.0:
		return remap(posOverride, 0.0, chartLength, nodeSize.y, 0.0)
	
	return remap(chartPos, 0.0, chartLength, nodeSize.y, 0.0)

## A simple helper function that determines if the inputed text is made up of just ASCII characters!
static func isASCII(input : String) -> bool:
	## A simple RegEX that returns true only when the input is purely made up of Ascii characters!
	var asciiRegEX = RegEx.create_from_string("^[[:ascii:]\\s]*$")
	
	if asciiRegEX.search(input) != null:
		return true
	
	return false

# Called when the plugin is first enabled
func _enable_plugin() -> void:
	pass

# Called when the plugin is disabled
func _disable_plugin() -> void:
	pass

# Setup function
func _enter_tree() -> void:
	#Initializes main plugin UI
	mainPanelInstance = MAINPANEL.instantiate()
	EditorInterface.get_editor_main_screen().add_child(mainPanelInstance)
	_make_visible(false) # Required!

# Cleanup
func _exit_tree() -> void:
	if mainPanelInstance:
		mainPanelInstance.queue_free()
	
	if currentChart != null:
		currentChart = null

# Just needs to contain return true
func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if mainPanelInstance:
		mainPanelInstance.visible = visible

func _get_plugin_name() -> String:
	return "ReMX Editor"

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
