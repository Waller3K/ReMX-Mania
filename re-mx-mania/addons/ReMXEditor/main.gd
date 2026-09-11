@tool
class_name ReMXEditor
extends EditorPlugin

const MAINPANEL = preload("res://addons/ReMXEditor/ReMXEditorScene.tscn")

# Global variables
## The current chartdata that is loaded into memory
static var currentChart : Chart = null

var mainPanelInstance : Node

## A simple helper function that deturmines if the inputed text is made up of just ASCII characters!
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
