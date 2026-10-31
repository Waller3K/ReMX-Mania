@tool
extends Button

func _ready() -> void:
	disabled = true

func _onChartLoadedInEditor() -> void:
	disabled = false

func _onChartClosed() -> void:
	disabled = true
