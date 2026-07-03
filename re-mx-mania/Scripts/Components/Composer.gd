extends Node

var chartData: Chart = Chart.new()
var chartPath: String = "res://Charts/Beginner.json"

signal chartCreated(chart: Chart)

func _ready() -> void:
	if chartData.load(chartPath):
		chartCreated.emit.call_deferred(chartData)
	else:
		print("Chart failed to load!")
