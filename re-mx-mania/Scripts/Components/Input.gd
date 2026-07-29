extends Node

var scratchActive : bool

signal btn1(inputTimestamp: float, isDown: bool)
signal btn2(inputTimestamp: float, isDown: bool)
signal btn3(inputTimestamp: float, isDown: bool)
signal btn4(inputTimestamp: float, isDown: bool)
signal btnFX(inputTimestamp: float, isDown: bool)
signal btnScratch(inputTimestamp: float, isDown: bool)

# Used to get the current YVelocity!
signal mouseMoved(inputTimestamp: float, YVelocity: float)

# Used to get whether or not the mouse is moving at all
signal mouseMoving(inputTimestamp: float, isMoving: bool)

var songPos : float

var isMouseMoving : bool

var lastYDir : float = 0.0

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
		# FORCE OFF if scratch button is let go while mouse was moving
		if isMouseMoving:
			isMouseMoving = false
			lastYDir = 0
			mouseMoving.emit(songPos, false)
	
	# Mouse Handling
	if event is InputEventMouseMotion and scratchActive:
		if !isMouseMoving:
			pass
		mouseMoved.emit(songPos, event.relative.y)

func _onSongUpdate(songPosition: float) -> void:
	songPos = songPosition * 1000
	
	# Additional Mouse Handling is moved here
	if !scratchActive:
		if isMouseMoving:
			isMouseMoving = false
			lastYDir = 0
			mouseMoving.emit(songPos, false)
		return
	
	var mouseVelocity : Vector2 = Input.get_last_mouse_velocity()
	
	var currentlyMoving : bool = mouseVelocity.length_squared() > 0
	
	if currentlyMoving:
		# Will either be -1.0 for Down, 1.0 for Up, or 0.0 for nothing
		var currentYDir = signf(mouseVelocity.y)
		
		if !isMouseMoving:
			isMouseMoving = true
			lastYDir = currentYDir
			mouseMoving.emit(songPos, true)
		# If the mouse has changed direction
		elif currentYDir != 0 and lastYDir != currentYDir:
			lastYDir = currentYDir
			mouseMoving.emit(songPos, true)
	else:
		if isMouseMoving:
			isMouseMoving = false
			lastYDir = 0
			mouseMoving.emit(songPos, false)
