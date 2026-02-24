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

var audioPath: String
var songPos: float = 0.0
var isPlaying = false

# This songUpdate signal will be used in other scripts to trigger updates in place of the _process function
signal songUpdate(timeStamp: float)

func _onChartCreation(chart: Chart) -> void:
	audioPath = chart.songPath
	syncStream = AudioStreamSynchronized.new()
	syncStream.stream_count = 5
	
	syncStream.set_sync_stream(0, load(chart.songPath))
	syncStream.set_sync_stream(1, load(chart.track1Path))
	syncStream.set_sync_stream(2, load(chart.track2Path))
	syncStream.set_sync_stream(3, load(chart.track3Path))
	syncStream.set_sync_stream(4, load(chart.track4Path))
	
	musicPlayer.stream = syncStream

func _process(_delta: float) -> void:
	if isPlaying:
		songPos = musicPlayer.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
		songUpdate.emit(songPos)


func _onTestButton() -> void:
	musicPlayer.play()
	isPlaying = true


func _onFinished():
	isPlaying = false
