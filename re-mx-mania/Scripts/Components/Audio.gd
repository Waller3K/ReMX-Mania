extends AudioStreamPlayer

@onready var musicPlayer : AudioStreamPlayer = $"."

var syncStream : AudioStreamSynchronized

# Variable for the volume offset to prevent clipping
var streamDBOffset : float = -10.0

var songPos: float 	= 0.0
var isPlaying 		= false

# -1 is no effect
var currentFXIndex : int = -1

var masterTrackIndex = AudioServer.get_bus_index("Master")

###################################################
# This signal will be used in place of _process()
# to trigger updates
###################################################
signal songUpdate(songPosition: float)

# func _onChartCreation(chart: Chart) -> void:

func _process(_delta: float) -> void:
	if isPlaying:
		songPos = musicPlayer.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() - (GlobalStates.globalOffset/1000)
		songUpdate.emit(songPos)
