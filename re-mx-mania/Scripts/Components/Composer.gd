extends Node

var chartData: Chart = Chart.new()

signal chartCreated(chart: Chart)

func _ready() -> void:
	chartData = GlobalStates.currentChartData
	
	if chartData != null:
		chartCreated.emit.call_deferred(chartData)
	else:
		print("Chart failed to load!")
