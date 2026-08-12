extends Node

var numOfNotes

@export var comboLabel : Label3D

var combo : int = 0

var maxCombo : int = 0

signal startSong(timeStamp: float)

func _onChartCreated(chart: Chart) -> void:
	GlobalStates.PRESONG_TIME = 5.0
	var secsPerBeat = 60/chart.bpm
	var metronomeSFX = "res://Assets/SFX/Closed_Hat_1.ogg"
	$MetronomePlayer.stream = load(metronomeSFX)
	
	await get_tree().create_timer(secsPerBeat*2).timeout
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
	maxCombo = combo if combo > maxCombo else maxCombo
	
	combo = 0
	
	comboLabel.text = str(combo) + " COMBO!"
	#print("MISS! " + str(trackIndex) + ", " + str(noteIndex))

func _onNoteHit(judgement: int, offset: float, trackIndex: int, noteIndex: int) -> void:
	
	combo += 1
	comboLabel.text = str(combo) + " COMBO!"


func _onHoldStarted(trackIndex: int, noteIndex: int, FX: int) -> void:
	pass


func _onHoldEnded(trackIndex: int, noteIndex: int, FX: int) -> void:
	pass


func _onHoldBroken(trackIndex: int, noteIndex: int, FX: int) -> void:
	combo = 0
	comboLabel.text = str(combo) + " COMBO!"


func _onScratchBreak(noteIndex: int, subnoteIndex: int) -> void:
	combo = 0
	comboLabel.text = str(combo) + " COMBO!"
	
	print("Scratch Broken! " + str(noteIndex) + ", " + str(subnoteIndex))


func _onScratchHit(judgement: int, offset: float, noteIndex: int, subnoteIndex: int) -> void:
	combo += 1
	comboLabel.text = str(combo) + " COMBO!"


func _onHoldTick(trackIndex: int, noteIndex: int) -> void:
	combo += 1
	comboLabel.text = str(combo) + " COMBO!"
