extends Control

@export var buttonScene : PackedScene

func _ready() -> void:
	loadCharts()
	

func loadCharts() -> void:
	# Iterates through the chart directories (Specified in the options menu)
	for chartDir : String in GlobalStates.chartDirectories:
		# Opens the file directory
		var openDir := DirAccess.open(chartDir)
		
		var chartFolders : PackedStringArray
		
		if !openDir:
			push_error("Error: Directory invalid - " + chartDir)
			continue
		
		chartFolders = openDir.get_directories()
		
		
		for chart in chartFolders:
			var openChartFolder := DirAccess.open(chartDir + "/" + chart)
			
			# Puts the chart.json files in the 
			var difficultySpread = Array(openChartFolder.get_files()).filter(func(f): return f.get_extension() == "json")
			
			for difficulty in difficultySpread:
				var fullChartPath = chartDir + "/" + chart + "/" + difficulty
				
				var newButton = buttonScene.instantiate()
				newButton.setPath(fullChartPath)
				
				add_child(newButton)
