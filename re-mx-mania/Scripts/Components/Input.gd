extends Node

var scratchActive : bool

signal btn1(inputTimestamp: float, isDown: bool)
signal btn2(inputTimestamp: float, isDown: bool)
signal btn3(inputTimestamp: float, isDown: bool)
signal btn4(inputTimestamp: float, isDown: bool)
signal btnFX(inputTimestamp: float, isDown: bool)
signal btnScratch(inputTimestamp: float, isDown: bool)

signal mouseMoved(inputTimestamp: float, YVelocity: float)

var songPos : float

func _ready() -> void:
	Input.use_accumulated_input = false
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	# Pressed Triggers
	if event.is_action_pressed("BTN 1"):
		btn1.emit(songPos, true)
	elif event.is_action_pressed("BTN 2"):
		btn2.emit(songPos, true)
	elif event.is_action_pressed("BTN 3"):
		btn3.emit(songPos, true)
	elif event.is_action_pressed("BTN 4"):
		btn4.emit(songPos, true)
	elif event.is_action_pressed("BTN FX"):
		btnFX.emit(songPos, true)
	elif event.is_action_pressed("BTN SCRATCH"):
		scratchActive = true
		btnScratch.emit(songPos, true)
	
	# Released Triggers
	if event.is_action_released("BTN 1"):
		btn1.emit(songPos, false)
	elif event.is_action_released("BTN 2"):
		btn2.emit(songPos, false)
	elif event.is_action_released("BTN 3"):
		btn3.emit(songPos, false)
	elif event.is_action_released("BTN 4"):
		btn4.emit(songPos, false)
	elif event.is_action_released("BTN FX"):
		btnFX.emit(songPos, false)
	elif event.is_action_released("BTN SCRATCH"):
		scratchActive = false
		btnScratch.emit(songPos, false)
	
	# Mouse Handling
	if event is InputEventMouseMotion and scratchActive:
		mouseMoved.emit(songPos, event.relative.y)

func _onSongUpdate(songPosition: float) -> void:
	songPos = songPosition * 1000
