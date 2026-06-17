##########################################################
# This is a little more complex of a script in my system
# This node will contain a bit more and will send out a 
# signal every frame that contains data on the song's 
# position.
##########################################################

extends AudioStreamPlayer

@onready var musicPlayer = $"."

# Variable for the AudioStreamSyncronized 
var syncStream: AudioStreamSynchronized
# Variable for the volume offset to prevent audio clipping issues
var streamDBOffset = -10.0

var songPos: float = 0.0
var isPlaying = false

# -1 is no effect
var currentFXIndex : int = -1

var masterTrackIndex = AudioServer.get_bus_index("Master")

# This songUpdate signal will be used in other scripts to trigger updates in place of the _process function
signal songUpdate(timeStamp: float)

func _onChartCreation(chart: Chart) -> void:
	syncStream = AudioStreamSynchronized.new()
	syncStream.stream_count = 5
	
	syncStream.set_sync_stream(0, load(chart.BGMPath))
	syncStream.set_sync_stream_volume(0, streamDBOffset)
	
	syncStream.set_sync_stream(1, load(chart.track1Path))
	syncStream.set_sync_stream_volume(1, streamDBOffset)
	
	syncStream.set_sync_stream(2, load(chart.track2Path))
	syncStream.set_sync_stream_volume(2, streamDBOffset)
	
	syncStream.set_sync_stream(3, load(chart.track3Path))
	syncStream.set_sync_stream_volume(3, streamDBOffset)
	
	syncStream.set_sync_stream(4, load(chart.track4Path))
	syncStream.set_sync_stream_volume(4, streamDBOffset)
	
	musicPlayer.stream = syncStream

func _process(_delta: float) -> void:
	if isPlaying:
		songPos = musicPlayer.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() - (GlobalStates.globalOffset/1000)
		songUpdate.emit(songPos)


func _onSongStart(_songStartTime: float) -> void:
	musicPlayer.play()
	isPlaying = true

func _onFinished():
	if GlobalStates.globalOffset > 0.0:
		await get_tree().create_timer(GlobalStates.globalOffset).timeout
	isPlaying = false


func _onGoodEarly(offset: float, trackIndex: int, noteIndex: int) -> void:
	musicPlayer.stream.set_sync_stream_volume(trackIndex + 1, streamDBOffset)


func _onGoodLate(offset: float, trackIndex: int, noteIndex: int) -> void:
	musicPlayer.stream.set_sync_stream_volume(trackIndex + 1, streamDBOffset)


func _onMiss(trackIndex: int, noteIndex: int) -> void:
	musicPlayer.stream.set_sync_stream_volume(trackIndex + 1, -50)


func _onOkEarly(offset: float, trackIndex: int, noteIndex: int) -> void:
	musicPlayer.stream.set_sync_stream_volume(trackIndex + 1, streamDBOffset)


func _onOkLate(offset: float, trackIndex: int, noteIndex: int) -> void:
	musicPlayer.stream.set_sync_stream_volume(trackIndex + 1, streamDBOffset)


func _onPerfect(offset: float, trackIndex: int, noteIndex: int) -> void:
	musicPlayer.stream.set_sync_stream_volume(trackIndex + 1, streamDBOffset)


func _onPerfectEarly(offset: float, trackIndex: int, noteIndex: int) -> void:
	musicPlayer.stream.set_sync_stream_volume(trackIndex + 1, streamDBOffset)

func _onPerfectLate(offset: float, trackIndex: int, noteIndex: int) -> void:
	musicPlayer.stream.set_sync_stream_volume(trackIndex + 1, streamDBOffset)



func _onHoldBroken(trackIndex, noteIndex, FX):
	if FX != -1:
		AudioServer.set_bus_effect_enabled(masterTrackIndex, FX, false)
		currentFXIndex = -1


func _onHoldEnded(trackIndex, noteIndex, FX):
	if FX != -1:
		AudioServer.set_bus_effect_enabled(masterTrackIndex, FX, false)
		currentFXIndex = -1


func _onHoldStarted(trackIndex, noteIndex, FX):
	if FX != -1:
		currentFXIndex = FX
		AudioServer.set_bus_effect_enabled(masterTrackIndex, FX, true)


func onInputBtnFX(inputTimestamp: float, isDown: bool) -> void:
	if !isDown:
		if currentFXIndex != -1:
			AudioServer.set_bus_effect_enabled(masterTrackIndex, currentFXIndex, false)
