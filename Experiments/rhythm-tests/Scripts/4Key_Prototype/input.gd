extends Node

signal testButton

####################################
# signals for buttons 1-4 that
# correspond to tracks 1-4
####################################
signal btn1(isDown: bool)
signal btn2(isDown: bool)
signal btn3(isDown: bool)
signal btn4(isDown: bool)

# FX button signal
signal btnFX(isDown: bool)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mainButton"):
		testButton.emit()
	elif event.is_action_pressed("Track 1"):
		btn1.emit(true)
	elif event.is_action_pressed("Track 2"):
		btn2.emit(true)
	elif event.is_action_pressed("Track 3"):
		btn3.emit(true)
	elif event.is_action_pressed("Track 4"):
		btn4.emit(true)
	elif event.is_action_pressed("FX_BTN"):
		btnFX.emit(true)
	
	if event.is_action_released("Track 1"):
		btn1.emit(false)
	elif event.is_action_released("Track 2"):
		btn2.emit(false)
	elif event.is_action_released("Track 3"):
		btn3.emit(false)
	elif event.is_action_released("Track 4"):
		btn4.emit(false)
	elif event.is_action_released("FX_BTN"):
		btnFX.emit(false)
