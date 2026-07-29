extends Node

var chartData: Chart = Chart.new()
var chartPath: String

signal chartCreated(chart: Chart)

func _ready() -> void:
	GlobalStates.currentChartPath = "res://Charts/Scratch Test Chart/Expert.json"
	chartPath = GlobalStates.currentChartPath
	
	if chartData.load(chartPath):
		chartCreated.emit.call_deferred(chartData)
	else:
		print("Chart failed to load!")
