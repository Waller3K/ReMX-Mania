@tool
class_name ReMXEditor
extends EditorPlugin

const MAINPANEL = preload("res://addons/ReMXEditor/ReMXEditorScene.tscn")

const AUTOLOAD_NAME = "PluginGlobals"
const AUTOLOAD_PATH = "res://addons/ReMXEditor/Scripts/Autoloads/globalVariables.gd"

var mainPanelInstance : Node

# Called when the plugin is first enabled
func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)

# Called when the plugin is disabled
func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)

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
