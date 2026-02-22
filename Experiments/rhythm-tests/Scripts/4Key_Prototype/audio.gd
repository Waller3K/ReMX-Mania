##########################################################
# This is a little more complex of a script in my system
# This node will contain a bit more and will send out a 
# signal every frame that contains data on the song's 
# position.
##########################################################

extends AudioStreamPlayer

@onready var musicPlayer = $"."

var audioPath: String
var songPos: float = 0.0
var isPlaying = false

# This songUpdate signal will be used in other scripts to trigger updates in place of the _process function
signal songUpdate(timeStamp: float)

func _onChartCreation(chart: Chart) -> void:
	audioPath = chart.songPath
	musicPlayer.stream = load(audioPath)

func _process(delta: float) -> void:
	if isPlaying:
		songPos = musicPlayer.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
		songUpdate.emit(songPos)
		print(songPos)


func _onTestButton() -> void:
	musicPlayer.play()
	isPlaying = true
