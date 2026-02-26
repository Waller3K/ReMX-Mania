extends Node

signal startSong

#################################################
# When the chart is created this function plays 
# a metronome for 4 beats before starting the song
#################################################
func _onChartCreation(chart: Chart) -> void:
	var secondsPerBeat = 60 / chart.bpm
	var clickSound : AudioStream = load("res://Assets/SFX/Closed_Hat_1.ogg")
	$MetronomePlayer.stream = clickSound
	await get_tree().create_timer(1.0).timeout # Give the player a chance to react
	$MetronomePlayer.play()
	await get_tree().create_timer(secondsPerBeat).timeout
	$MetronomePlayer.play()
	await get_tree().create_timer(secondsPerBeat).timeout
	$MetronomePlayer.play()
	await get_tree().create_timer(secondsPerBeat).timeout
	$MetronomePlayer.play()
	await get_tree().create_timer(secondsPerBeat).timeout
	startSong.emit()
	

func _onGoodEarly(offset, trackIndex):
	print("Good Early! " + str(offset))


func _onGoodLate(offset, trackIndex):
	print("Good Late! " + str(offset))


func _onMiss(trackIndex):
	print("Miss!") # Replace with function body.


func _onOkEarly(offset, trackIndex):
	print("OK Early! " + str(offset)) # Replace with function body.


func _onOkLate(offset, trackIndex):
	print("OK Late! " + str(offset))


func _onPerfect(offset, trackIndex):
	print("Perfect! " + str(offset))


func _onPerfectEarly(offset, trackIndex):
	print("Perfect Early! " + str(offset))


func _onPerfectLate(offset, trackIndex):
	print("Perfect Late! " + str(offset))
