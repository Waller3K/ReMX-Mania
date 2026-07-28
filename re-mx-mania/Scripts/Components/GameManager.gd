extends Node

var numOfNotes

signal startSong(timeStamp: float)

func _onChartCreated(chart: Chart) -> void:
	GlobalStates.PRESONG_TIME = 5.0
	var secsPerBeat = 60/chart.bpm
	var metronomeSFX = "res://Assets/SFX/Closed_Hat_1.ogg"
	$MetronomePlayer.stream = load(metronomeSFX)
	
	$MetronomePlayer.play()
	await get_tree().create_timer(secsPerBeat).timeout
	$MetronomePlayer.play()
	await get_tree().create_timer(secsPerBeat).timeout
	$MetronomePlayer.play()
	await get_tree().create_timer(secsPerBeat).timeout
	$MetronomePlayer.play()
	await get_tree().create_timer(secsPerBeat).timeout
	startSong.emit(Time.get_ticks_msec())

func updateScore(judgement: int) -> void:
	match judgement:
		pass

func _onMiss(trackIndex: int, noteIndex: int) -> void:
	print("MISS!")

func _onNoteHit(judgement: int, offset: float, trackIndex: int, noteIndex: int) -> void:
	match judgement:
		GlobalEnums.judgementEnum.PERFECT:
			print("PERFECT! - " + str(offset))
		GlobalEnums.judgementEnum.PERFECTEARLY:
			print("EPerfect - " + str(offset))
		GlobalEnums.judgementEnum.PERFECTLATE:
			print("LPerfect - " + str(offset))
		GlobalEnums.judgementEnum.GOODEARLY:
			print("Good Early - " + str(offset))
		GlobalEnums.judgementEnum.GOODLATE:
			print("Good Late - " + str(offset))
		GlobalEnums.judgementEnum.OKEARLY:
			print("OK Early - " + str(offset))
		GlobalEnums.judgementEnum.OKLATE:
			print("OK Late - " + str(offset))


func _onHoldStarted(trackIndex: int, noteIndex: int, FX: int) -> void:
	print("Hold Started, " + str(trackIndex))


func _onHoldEnded(trackIndex: int, noteIndex: int, FX: int) -> void:
	print("Hold Ended, " + str(trackIndex))


func _onHoldBroken(trackIndex: int, noteIndex: int, FX: int) -> void:
	print("Hold BROKEN! " + str(trackIndex))
