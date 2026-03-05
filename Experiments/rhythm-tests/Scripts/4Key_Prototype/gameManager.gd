extends Node

signal startSong

signal noteHit(track: int, note: int)

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
	

func _onGoodEarly(offset, trackIndex, noteIndex):
	print("Good Early! " + str(offset))
	noteHit.emit(trackIndex, noteIndex)
	pass


func _onGoodLate(offset, trackIndex, noteIndex):
	print("Good Late! " + str(offset))
	noteHit.emit(trackIndex, noteIndex)
	pass


func _onMiss(trackIndex, noteIndex):
	print("Miss!") # Replace with function body.
	noteHit.emit(trackIndex, noteIndex)
	pass


func _onOkEarly(offset, trackIndex, noteIndex):
	print("OK Early! " + str(offset)) # Replace with function body.
	noteHit.emit(trackIndex, noteIndex)
	pass


func _onOkLate(offset, trackIndex, noteIndex):
	print("OK Late! " + str(offset))
	noteHit.emit(trackIndex, noteIndex)
	pass


func _onPerfect(offset, trackIndex, noteIndex):
	print("Perfect! " + str(offset))
	noteHit.emit(trackIndex, noteIndex)
	pass


func _onPerfectEarly(offset, trackIndex, noteIndex):
	print("Perfect Early! " + str(offset))
	noteHit.emit(trackIndex, noteIndex)
	pass


func _onPerfectLate(offset, trackIndex, noteIndex):
	print("Perfect Late! " + str(offset))
	noteHit.emit(trackIndex, noteIndex)
	pass
