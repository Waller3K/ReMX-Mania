extends AudioStreamPlayer

@onready var musicPlayer : AudioStreamPlayer = $"."

var syncStream : AudioStreamSynchronized

@export var hitsoundPlayer : AudioStreamPlayer

var songPos: float 	= 0.0
var isPlaying 		= false
var isPreSong 		= false
var isPostSong		= false

var postSongTime : float = 0.0

var preSongTimer : Timer
var postSongTimer : Timer

# -1 is no effect
var currentFXIndex : int = -1

var musicTrackIndex = AudioServer.get_bus_index("Main Music")


###################################################
# This signal will be used in place of _process()
# to trigger updates
###################################################
signal songUpdate(songPosition: float)
signal chartEnded()


# Takes in the chart's path, and the given relative path, and returns the final joined path.
func getAbsolutePath(chartPath: String, relativePath: String) -> String:
	var baseDir : String = chartPath.get_base_dir()
	var finalPath = baseDir.path_join(relativePath)
	return finalPath.simplify_path()

func setTrackVolume(trackID : int, mute : bool):
	var streamIndex : int
	if trackID == GlobalEnums.trackIDs.TRACKFX:
		return
	elif trackID == GlobalEnums.trackIDs.SCRATCH_TRACK:
		streamIndex = 4
	else:
		streamIndex = trackID - 2
	
	if mute:
		musicPlayer.stream.set_sync_stream_volume(streamIndex, linear_to_db(0.0))
	else:
		musicPlayer.stream.set_sync_stream_volume(streamIndex, GlobalStates.musicVolumeDB - GlobalStates.streamDBOffset)

func toggleFX(FXID : int, isOn : bool):
	AudioServer.set_bus_effect_enabled(musicTrackIndex, FXID, isOn)

func _onChartCreated(chart: Chart) -> void:
	hitsoundPlayer.stream = load("res://Assets/SFX/Closed_Hat_1.ogg") # TODO: Make a hitsound selector in the settings menu
	
	hitsoundPlayer.volume_db = GlobalStates.sfxVolumeDB - GlobalStates.streamDBOffset
	
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
			load(getAbsolutePath(
					chart.getPath(), 
					chart.trackPaths[i])
				)
		)
		syncStream.set_sync_stream_volume(i, GlobalStates.musicVolumeDB - GlobalStates.streamDBOffset)
	
	syncStream.set_sync_stream(
		4, 
		load(getAbsolutePath(
				chart.getPath(), 
				chart.scratchTrackPath)
			)
	)
	syncStream.set_sync_stream_volume(4, GlobalStates.musicVolumeDB - GlobalStates.streamDBOffset)
	
	syncStream.set_sync_stream(
		5, 
		load(getAbsolutePath(
				chart.getPath(), 
				chart.BGMPath)
			)
	)
	syncStream.set_sync_stream_volume(5, GlobalStates.musicVolumeDB - GlobalStates.streamDBOffset)
	
	musicPlayer.stream = syncStream


func _process(delta: float) -> void:
	if isPlaying:
		var currentAudioPos = musicPlayer.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() - (GlobalStates.globalOffset/1000)
		# If the audio jumps backward by more than 0.5 seconds, it means it reset to 0
		if (songPos - currentAudioPos) > 0.5 :
			songPos = stream.get_length()
		else:
			songPos = currentAudioPos
		songUpdate.emit(songPos)
	elif isPreSong:
		songPos = (preSongTimer.get_time_left() * -1) - (GlobalStates.globalOffset/1000)
		songUpdate.emit(songPos)
	elif isPostSong:
		postSongTime += delta
		songPos = musicPlayer.stream.get_length() + postSongTime - (GlobalStates.globalOffset/1000)
		songUpdate.emit(songPos)

func startMusic() -> void:
	musicPlayer.play()
	isPlaying = true
	isPreSong = false


func _onSongStarted(_timeStamp: float) -> void:
	preSongTimer = Timer.new()
	preSongTimer.set_wait_time(GlobalStates.PRESONG_TIME)
	preSongTimer.autostart = true
	preSongTimer.timeout.connect(startMusic)
	preSongTimer.timeout.connect(preSongTimer.queue_free)
	isPreSong = true
	add_child(preSongTimer)


func endOfChart():
	chartEnded.emit()

func _onFinished() -> void:
	isPlaying = false
	isPostSong = true
	
	postSongTimer = Timer.new()
	postSongTimer.set_wait_time(GlobalStates.POSTSONG_TIME)
	postSongTimer.autostart = true
	postSongTimer.timeout.connect(endOfChart)
	postSongTimer.timeout.connect(postSongTimer.queue_free)
	add_child(postSongTimer)

# Normal note Hit and miss

func _onNoteHit(judgement: int, offset: float, trackIndex: int, noteIndex: int) -> void:
	setTrackVolume(trackIndex, false)
	hitsoundPlayer.play()

func _onMiss(trackIndex: int, noteIndex: int) -> void:
	setTrackVolume(trackIndex, true)

# Hold note hit end and break

func _onHoldStarted(trackIndex: int, noteIndex: int, FX: int) -> void:
	setTrackVolume(trackIndex, false)
	if FX == -1:
		return
	toggleFX(FX, true)

func _onHoldEnded(trackIndex: int, noteIndex: int, FX: int) -> void:
	setTrackVolume(trackIndex, false)
	if FX == -1:
		return
	toggleFX(FX, false)

func _onHoldBroken(trackIndex: int, noteIndex: int, FX: int) -> void:
	setTrackVolume(trackIndex, true)
	if FX == -1:
		return
	toggleFX(FX, false)

# Scratch track Hit and miss

func _onScratchHit(judgement: int, offset: float, noteIndex: int, subnoteIndex: int) -> void:
	setTrackVolume(GlobalEnums.trackIDs.SCRATCH_TRACK, false)


func _onScratchBreak(noteIndex: int, subnoteIndex: int) -> void:
	setTrackVolume(GlobalEnums.trackIDs.SCRATCH_TRACK, true)
