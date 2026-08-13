extends Control

func _ready() -> void:
	loadCharts()

func loadCharts() -> void:
	for chartDir : String in GlobalStates.chartDirectories:
		var openDir := DirAccess.open(chartDir)
		
		var chartFolders : PackedStringArray
		
		if openDir:
			chartFolders = openDir.get_directories()
		else:
			push_error("Error: Chart directory invalid!")
