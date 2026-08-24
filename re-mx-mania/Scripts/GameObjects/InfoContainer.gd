extends VBoxContainer

@export var FPSLable : Label
@export var SongPositionLable : Label
@export var trackActiveBoolLable : Label
@export var trackNextNoteIndexLabel: Label

func _ready() -> void:
	if GlobalStates.isDebug == false:
		visible = false

func _process(_delta : float) -> void:
	FPSLable.text = str(Engine.get_frames_per_second()) + " FPS"

func _onSongUpdate(songPosition: float) -> void:
	SongPositionLable.text = "SongPos: " + str(songPosition)
	

func _onDebugInfo(trackArray: Array[TrackState]) -> void:
	var trackActiveBools : Array[bool]
	var trackNNIs : Array[int]
	for track in trackArray:
		trackActiveBools.push_back(track.isActive)
		trackNNIs.push_back(track.nextNoteIndex)
	
	trackActiveBoolLable.text = "Track isActive States: " + str(trackActiveBools)
	trackNextNoteIndexLabel.text = "Track Next Note Indices: "  + str(trackNNIs)
