extends VBoxContainer

@export var FPSLable : Label
@export var SongPositionLable : Label

func _process(_delta : float) -> void:
	FPSLable.text = str(Engine.get_frames_per_second()) + " FPS"

func _onSongUpdate(songPosition: float) -> void:
	SongPositionLable.text = "SongPos: " + str(songPosition)
