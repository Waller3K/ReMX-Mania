extends Node

signal testButton

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mainButton"):
		testButton.emit()
