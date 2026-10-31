@tool
extends AudioStreamPlayer

var syncStream : AudioStreamSynchronized

func _ready() -> void:
	finished.connect(_onStop)

## Takes in the chart's path, and the given relative path, and returns the final joined path.
func getAbsolutePath(chartPath: String, relativePath: String) -> String:
	var baseDir : String = chartPath.get_base_dir()
	var finalPath = baseDir.path_join(relativePath)
	return finalPath.simplify_path()

## A helperfunction that is used to load the correct AudioStream type depending on the file type!
## Supports : .Ogg, .Mp3, and .wav
func loadRawAudio(path : String) -> AudioStream:
	# Returns the file extension in all lowercase so if it was OGG or Ogg it would 
	# resolve down to ogg
	var extension = path.get_extension().to_lower()
	var audioStream : AudioStream
	
	if extension == "mp3":
		audioStream = AudioStreamMP3.load_from_file(path)
	elif extension == "ogg":
		audioStream = AudioStreamOggVorbis.load_from_file(path)
	elif extension == "wav":
		audioStream = AudioStreamWAV.load_from_file(path)
	else:
		push_error("Error unsuported audio type: " + path)
		return null
	
	return audioStream

func _process(delta: float) -> void:
	# Checks to see if this scene is currently being editted!
	# Stops code from running in the open editor instance if 
	# it is.
	if is_part_of_edited_scene():
		return
	
	
	if ReMXEditor.isPlaying:
		var currentAudioPos = get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() - (ReMXEditor.globalOffset/1000)
		# If the audio jumps backward by more than 0.5 seconds, it means it reset to 0
		if (ReMXEditor.chartPos - currentAudioPos) > 0.5 :
			ReMXEditor.chartPos = stream.get_length()
		else:
			ReMXEditor.chartPos = currentAudioPos
	else:
		ReMXEditor.chartPos = 0.0
	

## Loads audio streams into editor stream player
func _onChartLoadedInEditor() -> void:
	var chart : Chart = ReMXEditor.currentChart
	
	syncStream = AudioStreamSynchronized.new()
	
	#######################################################
	# The stream_count is always the number of main
	# tracks + 2 (For the BG Track and the Scratch Track)
	#######################################################
	syncStream.stream_count = 6
	
	# Main Audio Tracks
	for i in 4 :
		syncStream.set_sync_stream(
			i, 
			loadRawAudio(getAbsolutePath(
					chart.getPath(), 
					chart.trackPaths[i])
				)
		)
		syncStream.set_sync_stream_volume(i, ReMXEditor.editorVolumeDB - ReMXEditor.VOLUME_OFFSET_DB)
	
	syncStream.set_sync_stream(
		4, 
		loadRawAudio(getAbsolutePath(
				chart.getPath(), 
				chart.scratchTrackPath)
			)
	)
	syncStream.set_sync_stream_volume(4, ReMXEditor.editorVolumeDB - ReMXEditor.VOLUME_OFFSET_DB)
	
	syncStream.set_sync_stream(
		5, 
		loadRawAudio(getAbsolutePath(
				chart.getPath(), 
				chart.BGMPath)
			)
	)
	syncStream.set_sync_stream_volume(5, ReMXEditor.editorVolumeDB - ReMXEditor.VOLUME_OFFSET_DB)
	
	stream = syncStream
	
	ReMXEditor.chartLength = stream.get_length()
	print("Chart Length = " + str(ReMXEditor.chartLength))


func _onChartClosed() -> void:
	if ReMXEditor.isPlaying:
		stop()
		ReMXEditor.isPlaying = false
	stream = null


func _onPlay() -> void:
	if !ReMXEditor.isPlaying:
		if ReMXEditor.pausedAt != -1.0:
			play(ReMXEditor.pausedAt)
		else:
			play()
		ReMXEditor.isPlaying = true


func _onPause() -> void:
	if ReMXEditor.isPlaying:
		# Set paused at to current timestamp
		ReMXEditor.pausedAt = ReMXEditor.chartPos
		stop()
		ReMXEditor.isPlaying = false


func _onStop() -> void:
	if ReMXEditor.isPlaying:
		# Reset pausedAt variable
		ReMXEditor.pausedAt = -1.0
		stop()
		ReMXEditor.isPlaying = false
