@tool
extends Panel

var playheadPos : int

func _ready() -> void:
	pass

func _draw() -> void:
	draw_line(Vector2i(0,playheadPos), Vector2i(size.x,playheadPos), Color(0.1,0.4,0.8), 5)

func _process(_delta) -> void:
	if(ReMXEditor.isPlaying):
		playheadPos = ReMXEditor.chartPosToScreenPos(size)
	else:
		if ReMXEditor.pausedAt != -1.0:
			playheadPos = ReMXEditor.chartPosToScreenPos(size, ReMXEditor.pausedAt)
		else:
			playheadPos = size.y
	
	queue_redraw()

func _onChartLoaded() -> void:
	# TODO: Add in the waveforms for each audio track here!
	pass

func _onSceneResized() -> void:
	queue_redraw()
