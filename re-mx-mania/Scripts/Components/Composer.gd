extends Node

var chartData: Chart = Chart.new()
var chartPath: String

signal chartCreated(chart: Chart)

func _ready() -> void:
	chartPath = GlobalStates.currentChartPath
	
	if chartPath == null:
		push_error("Error: No chart path specified!")
	
	if chartData.load(chartPath):
		chartCreated.emit.call_deferred(chartData)
	else:
		print("Chart failed to load!")
