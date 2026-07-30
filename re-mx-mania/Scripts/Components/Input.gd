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
signal mouseMoving(inputTimestamp: float, isMoving: bool, YDirection : int)

var songPos : float = -100000

var isMouseMoving : bool = false

var lastYDir : int

var lastMoveSongPos : float = 0.0

const mouseTimeOut : float = 60.0

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
			mouseMoving.emit(songPos, false, lastYDir)
	
	# Mouse Handling
	if event is InputEventMouseMotion and scratchActive:
		
		mouseMoved.emit(songPos, event.relative.y)
		
		var currentYDir : int  = signi(int(event.relative.y)) # -1 is Up 1 is Down 0 is Idle
		
		# Ignore inputs that are below the deadzone
		if abs(event.relative.y) < GlobalStates.scratchDeadzone:
			return
		
		# Mouse starts moving from nothing
		if lastYDir == 0:
			mouseMoving.emit(songPos, true, currentYDir)
			lastYDir = currentYDir
			isMouseMoving = true
		# Mouse changed direction
		elif currentYDir != lastYDir:
			mouseMoving.emit(songPos, true, currentYDir)
			lastYDir = currentYDir
			isMouseMoving = true
		
		lastMoveSongPos = songPos

func _onSongUpdate(songPosition: float) -> void:
	songPos = songPosition * 1000
	
	if isMouseMoving and (songPos - lastMoveSongPos) > mouseTimeOut:
		isMouseMoving = false
		lastYDir = 0
		mouseMoving.emit(songPos - mouseTimeOut, false, lastYDir)
