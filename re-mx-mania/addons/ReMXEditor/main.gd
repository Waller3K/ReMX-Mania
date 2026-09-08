@tool
class_name ReMXEditor
extends EditorPlugin

# Setup function
func _enter_tree() -> void:
	pass

# Cleanup
func _exit_tree() -> void:
	pass

# Just needs to contain return true
func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	pass

func _get_plugin_name() -> String:
	return "ReMX Editor"

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
