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

func _ready() -> void:
	var index = 0
	for track : ColorRect in tracks:
		track.draw.connect(drawNotes.bind(index, track))
		index += 1
	
	trackContainer.draw.connect(drawTrackContainer)

func _process(delta : float) -> void:
	if is_part_of_edited_scene():
		return
	
	trackContainer.queue_redraw()
	
	for track : ColorRect in tracks:
		track.queue_redraw()

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
			
			track.draw_rect(holdRect, Color(0.0, 0.656, 0.873, 1.0))
			continue
		
		track.draw_line(Vector2(0, noteY),Vector2(track.size.x, noteY),Color(0.733, 0.049, 1.0, 1.0), 5.0)


func drawTrackContainer():
	if !chartLoaded:
		return
	
	drawGrid(trackContainer)

func drawGrid(node : CanvasItem) -> void:
	var secsPerBeat : float = 60.0 / float(BPM)
	
	var numOfLines : int = 50
	
	var index : int = -25
	
	var nearestBeatInSeconds = floori(ReMXEditor.chartPos/secsPerBeat) * secsPerBeat
	
	for i in numOfLines:
		var lineY = ReMXEditor.chartPosToScreenPos(node.size, nearestBeatInSeconds - ((secsPerBeat/4) * index), true)
		node.draw_line(Vector2(0.0, lineY),  Vector2(node.size.x, lineY), Color(0.27, 0.27, 0.27, 1.0))
		index += 1
	


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
