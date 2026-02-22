extends Node

var chartData: Chart = Chart.new()
var chartPath: String = "res://Assets/Charts/4_Key_Charts/Test_Chart.json"

signal chartCreated(chart: Chart)

func _ready() -> void:
	if chartData.load(chartPath):
		chartCreated.emit.call_deferred(chartData)
	else:
		print("Chart could not be loaded")
