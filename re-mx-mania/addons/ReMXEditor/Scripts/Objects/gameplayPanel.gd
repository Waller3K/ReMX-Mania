@tool
extends Panel

enum trackIDs {
	TRACKFX,
	SCRATCH_TRACK,
	TRACK1,
	TRACK2,
	TRACK3,
	TRACK4,
}

@export var tracks : Array[ColorRect]

@export var trackContainer : HBoxContainer

## The buttons are ordered track 1-4 (Indecies 0-3) and then FX Track (index 4)
@export var buttons : Array[ColorRect]

var chartLoaded : bool = false

var BPM : float = 0.0

var secsPerBeat : float

## Contains the raw mouse state! isActive, activeTrack, yPos, chartPos
var mouseState : Dictionary = {
	"isActive" = false,
	"activeTrack" = -1,
	"yPos" = 0.0
}


## The position of the cursor where notes will be placed in PIXELS
var cursorPos : float = 0.0

## The position of the cursor where notes will be placed in SECONDS
var cursorChartPos : float = 0.0

func _ready() -> void:
	var index = 0
	for track : ColorRect in tracks:
		track.draw.connect(draw.bind(index as trackIDs, track))
		
		if track == tracks[trackIDs.TRACKFX]:
			# TODO: add FX Track specific connections here!
			index += 1
			continue
		
		if track == tracks[trackIDs.SCRATCH_TRACK]:
			# TODO: add Scratch Track Specific connections here!
			index += 1
			continue
		
		track.mouse_entered.connect(toggleMouseActive.bind(index as trackIDs, true))
		track.mouse_exited.connect(toggleMouseActive.bind(index as trackIDs, false))
		index += 1
	
	trackContainer.draw.connect(drawTrackContainer)

func _process(delta : float) -> void:
	if is_part_of_edited_scene():
		return
	
	trackContainer.queue_redraw()
	
	for track : ColorRect in tracks:
		track.queue_redraw()
	
	updateCursor()

func updateCursor():
	if ReMXEditor.isSnapping:
		var rawChartPos : float = ReMXEditor.screenPosToChartPos(
			tracks[mouseState["activeTrack"]].size, 
			cursorPos, 
			true
			)
		
		## The length of a snap segment (In Seconds)
		var snapInterval = secsPerBeat/ReMXEditor.gridSnap
		
		cursorChartPos = snappedf(rawChartPos, snapInterval)
		cursorPos = ReMXEditor.chartPosToScreenPos(
			tracks[mouseState["activeTrack"]].size, 
			cursorChartPos, 
			true
		)
		return
	
	cursorPos = mouseState["yPos"]
	cursorChartPos = ReMXEditor.screenPosToChartPos(
			tracks[mouseState["activeTrack"]].size, 
			cursorPos, 
			true
			)

func draw(trackID : trackIDs, track : CanvasItem) -> void:
	drawNotes(trackID, track)
	if mouseState["isActive"] && mouseState["activeTrack"] == trackID:
		drawCursor(cursorPos, track)

func drawNotes(trackID : int, track : CanvasItem) -> void:
	if !chartLoaded || track.is_part_of_edited_scene():
		return
	
	for note : Dictionary in ReMXEditor.currentChart.notes[trackID]:
		var noteY = ReMXEditor.chartPosToScreenPos(track.size, note["Pos"], true)
		if note.has("End"):
			var endY = ReMXEditor.chartPosToScreenPos(track.size, note["End"], true)
			var holdRect : Rect2 = Rect2(0.0, endY, track.size.x, noteY - endY)
			
			if trackID == trackIDs.TRACKFX:
				track.draw_rect(holdRect, Color(1.0, 0.339, 0.339, 1.0))
				track.draw_string(ReMXEditor.defaultFont, Vector2(track.size.x/2, noteY - 8), str(note["Effect"]))
				continue
			
			if note.has("Subnotes"):
				track.draw_rect(holdRect, Color(0.812, 0.536, 0.0, 1.0))
				for subnote in note["Subnotes"]:
					var subnotePos = subnote["Pos"]
					var subnoteType : int = int(subnote["Type"])
					
					var subnoteY = ReMXEditor.chartPosToScreenPos(
						track.size, 
						subnotePos, 
						true
						)
					
					var subnoteString : String
					
					match subnoteType:
						0:
							subnoteString = "---^^vv---"
						1:
							subnoteString = "---^^^^---"
						2:
							subnoteString = "---vvvv---"
						_:
							subnoteString = "---????---"
					
					track.draw_line(Vector2(0.0, subnoteY), Vector2(track.size.x, subnoteY), Color(0.541, 0.204, 0.596, 1.0), 5.0)
					
					track.draw_string(
						ReMXEditor.defaultFont, 
						Vector2(track.size.x/2, subnoteY), 
						subnoteString,
						HORIZONTAL_ALIGNMENT_CENTER
						)
				continue
			
			track.draw_rect(holdRect, Color(0.0, 0.656, 0.873, 1.0))
			continue
		
		track.draw_line(Vector2(0, noteY),Vector2(track.size.x, noteY),Color(0.733, 0.049, 1.0, 1.0), 5.0)

func drawCursor(mouseYPos : float, track : CanvasItem):
	track.draw_line(Vector2(0.0, mouseYPos), Vector2(track.size.x, mouseYPos), Color(0.75, 0.0, 0.8, 0.5), 3)

func drawTrackContainer():
	if !chartLoaded:
		return
	
	drawGrid(trackContainer)

func drawGrid(node : CanvasItem) -> void:
	if !ReMXEditor.isSnapping:
		return
	
	secsPerBeat = 60.0 / BPM
	
	var numOfLines : int = 50
	
	var index : int = -25
	
	var nearestBeatInSeconds = floori(ReMXEditor.chartPos/secsPerBeat) * secsPerBeat
	
	for i in numOfLines:
		var lineY = ReMXEditor.chartPosToScreenPos(node.size, 
			nearestBeatInSeconds - ((secsPerBeat/ReMXEditor.gridSnap) * index), 
			true
			)
		node.draw_line(Vector2(0.0, lineY),  Vector2(node.size.x, lineY), Color(0.27, 0.27, 0.27, 1.0))
		index += 1

func toggleMouseActive(trackID : trackIDs, isActive : bool):
	mouseState["isActive"] = isActive
	mouseState["activeTrack"] = trackID

# ********************* Tool Functions!!! ********************* #

func tapTool(activeTrack : int, mouseButton : InputEventMouseButton, mouseChartPos : float):
	if activeTrack == -1 || activeTrack < trackIDs.TRACK1 || mouseButton.is_pressed() == false:
		return
	
	match mouseButton.button_index:
		MOUSE_BUTTON_LEFT:
			ReMXEditor.currentChart.addMainNote(activeTrack, mouseChartPos)

func _onChartLoadedInEditor() -> void:
	if chartLoaded:
		_onChartClosed()
	
	var trackCount = ReMXEditor.currentChart.trackCount
	
	if trackCount >= 3:
		tracks[trackIDs.TRACK3].visible = true
		buttons[2].visible = true
	
	if trackCount == 4:
		tracks[trackIDs.TRACK4].visible = true
		buttons[3].visible = true
	
	BPM = ReMXEditor.currentChart.bpm
	
	chartLoaded = true

func _onChartClosed() -> void:
	tracks[trackIDs.TRACK3].visible = false
	tracks[trackIDs.TRACK4].visible = false
	buttons[2].visible = false
	buttons[3].visible = false
	
	BPM = 0.0
	
	chartLoaded = false

func _gui_input(event: InputEvent) -> void:
	if is_part_of_edited_scene():
		return
	
	# Mouse Section
	
	if !mouseState["isActive"]:
		return
	
	if event is InputEventMouseButton:
		if !ReMXEditor.currentChart:
			return
		
		var mouseButton : InputEventMouseButton = event
		
		match ReMXEditor.currentTool:
			ReMXEditor.toolEnum.TAP:
				tapTool(mouseState["activeTrack"], mouseButton, cursorChartPos)
	
	if event is InputEventMouseMotion:
		var mouseMotion : InputEventMouseMotion = event
		mouseState["yPos"] = mouseMotion.position.y
