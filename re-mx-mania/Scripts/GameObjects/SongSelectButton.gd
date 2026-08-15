extends Button

@export var chart : Chart


func setChart(chartData : Chart) -> void:
	chart = chartData

func setSongInfo(songTitle : String, artistName :  String):
	text = songTitle + " - " + artistName
