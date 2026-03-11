extends Node

signal testButton

var songStart = 0

var songPos = 0.0

####################################
# signals for buttons 1-4 that
# correspond to tracks 1-4
####################################
signal btn1(inputTimestamp: float, isDown: bool)
signal btn2(inputTimestamp: float, isDown: bool)
signal btn3(inputTimestamp: float, isDown: bool)
signal btn4(inputTimestamp: float, isDown: bool)

# FX button signal
signal btnFX(isDown: bool)

func _ready() -> void:
	Input.use_accumulated_input = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("testButton"):
		testButton.emit()
	elif event.is_action_pressed("Track 1"):
		btn1.emit(songPos, true)
	elif event.is_action_pressed("Track 2"):
		btn2.emit(songPos, true)
	elif event.is_action_pressed("Track 3"):
		btn3.emit(songPos, true)
	elif event.is_action_pressed("Track 4"):
		btn4.emit(songPos, true)
	elif event.is_action_pressed("FX_BTN"):
		btnFX.emit(songPos, true)
	
	if event.is_action_released("Track 1"):
		btn1.emit(songPos, false)
	elif event.is_action_released("Track 2"):
		btn2.emit(songPos, false)
	elif event.is_action_released("Track 3"):
		btn3.emit(songPos, false)
	elif event.is_action_released("Track 4"):
		btn4.emit(songPos, false)
	elif event.is_action_released("FX_BTN"):
		btnFX.emit(songPos, false)


func _onSongStart(songStartTime):
	songStart = songStartTime

func _onSongUpdate(timeStamp):
	songPos = timeStamp * 1000
