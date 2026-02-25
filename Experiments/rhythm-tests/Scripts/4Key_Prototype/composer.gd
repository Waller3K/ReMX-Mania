extends Node

var chartData: Chart = Chart.new()
var chartPath: String = "res://Assets/Charts/4_Key_Charts/Sink_to_a_deep_Sea_World.json"

signal chartCreated(chart: Chart)

func _ready() -> void:
	if chartData.load(chartPath):
		# This signal emits on the next frame to avoid
		# sending it out before the other nodes are ready
		chartCreated.emit.call_deferred(chartData) 
	else:
		print("Chart could not be loaded")
