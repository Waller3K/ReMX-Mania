extends Node

var numOfNotes

@export var comboLabel : Label3D

var results : Results = Results.new()

var combo : int = 0

var numOfHitNotes : int = 0

signal startSong(timeStamp: float)

func _onChartCreated(chart: Chart) -> void:
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
	results.hitBreakdown[judgement] += 1
	match judgement:
		pass

func updateCombo(isBroken : bool):
	if isBroken:
		combo = 0
		comboLabel.text = str(combo) + " COMBO!"
		return
	combo += 1
	numOfHitNotes += 1
	
	if combo>results.maxCombo:
		results.maxCombo = combo
	
	comboLabel.text = str(combo) + " COMBO!"

func _onMiss(trackIndex: int, noteIndex: int) -> void:
	updateCombo(true)
	updateScore(GlobalEnums.judgementEnum.MISS)
	#print("MISS! " + str(trackIndex) + ", " + str(noteIndex))

func _onNoteHit(judgement: int, offset: float, trackIndex: int, noteIndex: int) -> void:
	updateScore(judgement)
	updateCombo(false)


func _onHoldStarted(trackIndex: int, noteIndex: int, FX: int) -> void:
	pass


func _onHoldEnded(trackIndex: int, noteIndex: int, FX: int) -> void:
	pass


func _onHoldBroken(trackIndex: int, noteIndex: int, FX: int) -> void:
	updateCombo(true)
	updateScore(GlobalEnums.judgementEnum.MISS)


func _onScratchBreak(noteIndex: int, subnoteIndex: int) -> void:
	updateCombo(true)
	updateScore(GlobalEnums.judgementEnum.MISS)
	print("Scratch Broken! " + str(noteIndex) + ", " + str(subnoteIndex))


func _onScratchHit(judgement: int, offset: float, noteIndex: int, subnoteIndex: int) -> void:
	updateScore(judgement)
	updateCombo(false)


func _onHoldTick(trackIndex: int, noteIndex: int) -> void:
	updateScore(GlobalEnums.judgementEnum.PERFECT)
	updateCombo(false)


func _onChartEnded():
	SceneManager.loadResultsScreen(results)
