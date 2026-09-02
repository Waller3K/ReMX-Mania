extends Control

@export var buttonScene : PackedScene
@export var chartListScene : PackedScene
@export var previewPlayer : AudioStreamPlayer

var activeChartList : Node

func _ready() -> void:
	loadCharts()

func loadCharts() -> void:
	# Iterates through the chart directories (Specified in the options menu)
	for chartDir : String in GlobalStates.chartDirectories:
		# Opens the file directory
		var openDir := DirAccess.open(chartDir)
		
		if !openDir:
			push_error("Error: Directory invalid - " + chartDir)
			continue
		
		var chartFolders : PackedStringArray = openDir.get_directories()
		
		for songFolder in chartFolders:
			var songPath := chartDir + "/" + songFolder
			var openChartFolder := DirAccess.open(songPath)
			
			print(songPath)
			
			# Puts the chart.json files in the 
			var difficultyFiles = Array(openChartFolder.get_files()).filter(func(f): return f.get_extension() == "json")
			
			if difficultyFiles.is_empty():
				continue
			
			var songCharts : Array[Chart] = []
			
			for difficultyFile in difficultyFiles:
				var chart : Chart = Chart.new()
				if chart.load(songPath + "/" + difficultyFile):
					songCharts.append(chart)
			
			if songCharts.is_empty():
				continue
			
			var songEntry = buttonScene.instantiate()
			songEntry.setSongInfo(songCharts[0].songName, songCharts[0].songArtist)
			add_child(songEntry)
			
			
			var chartList = chartListScene.instantiate()
			chartList.init(songCharts)
			add_child(chartList)
			
			songEntry.pressed.connect(toggleCharts.bind(chartList, songCharts[0]))
			

## Takes in the chart's path, and the given relative path, and returns the final joined path.
func getAbsolutePath(chartPath: String, relativePath: String) -> String:
	var baseDir : String = chartPath.get_base_dir()
	var finalPath = baseDir.path_join(relativePath)
	return finalPath.simplify_path()

## This function toggles the visibility of a given chartList node and starts playing 
## the chart's song from the preview point.
func toggleCharts(chartList : Node, chartData: Chart):
	
	if activeChartList == null:
		activeChartList = chartList
	elif activeChartList != chartList:
		activeChartList.toggle()
		previewPlayer.stop()
		activeChartList = chartList
	
	chartList.toggle()
	
	var syncStream := AudioStreamSynchronized.new()
	
	syncStream.stream_count = 6
	
	if chartList.getIsOpen() == true:
		for i in range(4):
			var streamPath = getAbsolutePath(chartData.getPath(), chartData.trackPaths[i])
			syncStream.set_sync_stream(i, load(streamPath))
			syncStream.set_sync_stream_volume(i, GlobalStates.musicVolumeDB - GlobalStates.streamDBOffset)
		
		
		syncStream.set_sync_stream(4, load(getAbsolutePath(chartData.getPath(), chartData.BGMPath)))
		syncStream.set_sync_stream_volume(4, GlobalStates.musicVolumeDB - GlobalStates.streamDBOffset)
		
		syncStream.set_sync_stream(5, load(getAbsolutePath(chartData.getPath(), chartData.scratchTrackPath)))
		syncStream.set_sync_stream_volume(5, GlobalStates.musicVolumeDB - GlobalStates.streamDBOffset)
		
		previewPlayer.stream = syncStream
		previewPlayer.play(chartData.previewTimestamp)
	else:
		previewPlayer.stop()
		activeChartList = null
