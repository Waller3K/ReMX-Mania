@tool
extends Panel

var playheadPos : int

var mouseActive : bool = false
var isDragging : bool = false

var mouseY : float = 0.0

var chartLoaded : bool = false

var cursorColor : Color = Color(0.1,0.4,0.8)
var cursorGhostColor : Color = Color(0.1,0.4,0.8,0.5)

func drawCursor():
	draw_line(Vector2i(0,playheadPos), Vector2i(size.x,playheadPos), cursorColor, 5)

func drawGhostCursor():
	if !mouseActive:
		return
	
	draw_line(Vector2i(0,mouseY), Vector2i(size.x,mouseY), cursorGhostColor, 5)

func _ready() -> void:
	mouse_entered.connect(toggleMouseActive.bind(true))
	mouse_exited.connect(toggleMouseActive.bind(false))

func _draw() -> void:
	if is_part_of_edited_scene():
		return
	drawGhostCursor()
	drawCursor()

func _process(_delta) -> void:
	if(ReMXEditor.isPlaying):
		playheadPos = ReMXEditor.chartPosToScreenPos(size)
	else:
		if isDragging:
			playheadPos = mouseY
			ReMXEditor.setChartPos(ReMXEditor.screenPosToChartPos(size, mouseY))
			queue_redraw()
			return
		if ReMXEditor.pausedAt != -1.0:
			playheadPos = ReMXEditor.chartPosToScreenPos(size, ReMXEditor.pausedAt)
		else:
			playheadPos = size.y
	
	queue_redraw()

func toggleMouseActive(isActive : bool):
	mouseActive = isActive
	if mouseActive:
		if ReMXEditor.isPlaying || !chartLoaded:
			mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		else:
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		mouse_default_cursor_shape = Control.CURSOR_ARROW

func _gui_input(event: InputEvent) -> void:
	
	
	# Mouse Section!
	
	if !mouseActive:
		return
	
	if event is InputEventMouseButton:
		var mouseButton : InputEventMouseButton = event
		
		if !ReMXEditor.currentChart:
			return
		
		match mouseButton.button_index:
			MOUSE_BUTTON_LEFT:
				var newChartPos = ReMXEditor.screenPosToChartPos(size, mouseY)
				
				if mouseButton.is_pressed():
					isDragging = true
				else:
					isDragging = false
				
				if !ReMXEditor.isPlaying:
					ReMXEditor.setChartPos(ReMXEditor.screenPosToChartPos(size, mouseY))
				
	
	if event is InputEventMouseMotion:
		var mouseMotion : InputEventMouseMotion = event
		mouseY = mouseMotion.position.y

func _onChartLoaded() -> void:
	# TODO: Add in the waveforms for each audio track here!
	chartLoaded = true
	pass

func _onSceneResized() -> void:
	queue_redraw()


func _onChartClosed() -> void:
	ReMXEditor.setChartPos(0.0)
	chartLoaded = false
	# TODO: Cleanup the waveforms for each audio track here!
