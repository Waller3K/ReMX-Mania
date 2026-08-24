extends Node

@export var comboLabel : Label3D

var results : Results = Results.new()

var combo : int = 0

var scoreMult : int = 1

var numOfHitNotes : int = 0

## The score given per PERFECT note
var PerfectScore : int

## This chart's maximum weighted score
var maxWScore : int = 0

signal startSong(timeStamp: float)

signal scoreUpdate(score : int)

func _onChartCreated(chart: Chart) -> void:
	var secsPerBeat = 60/chart.bpm
	var metronomeSFX = "res://Assets/SFX/Closed_Hat_1.ogg"
	$MetronomePlayer.stream = load(metronomeSFX)
	
	# Setup and calculate max weighted score
	
	PerfectScore = GlobalStates.MAXIMUM_SCORE / chart.numOfNotes
	
	maxWScore = calculateMaxScore(chart.numOfNotes, PerfectScore)
	
	print("Max Score = " + str(maxWScore))
	
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

func calculateMaxScore(noteCount : int, PScore : float) -> float:
	var oneXNotes = min(noteCount, GlobalStates.twoXBoundary - 1)
	var twoXNotes = min(
		max(noteCount - (GlobalStates.twoXBoundary - 1), 0), 
		GlobalStates.threeXBoundary - GlobalStates.twoXBoundary
	)
	var threeXNotes = min(
		max(noteCount -  (GlobalStates.threeXBoundary - 1), 0), 
		GlobalStates.fourXBoundary - GlobalStates.threeXBoundary
	)
	var fourXNotes = max(noteCount - (GlobalStates.fourXBoundary - 1), 0)
	
	return PScore * (
		oneXNotes +
		twoXNotes * 2 +
		threeXNotes * 3 +
		fourXNotes * 4
	)

func updateScore(judgement : GlobalEnums.judgementEnum) -> void:
	results.hitBreakdown[judgement] += 1
	var score : int = 0
	var TScore : int = 0
	
	match judgement:
		GlobalEnums.judgementEnum.MISS:
			score += 0
			TScore += 0
		GlobalEnums.judgementEnum.OKLATE, GlobalEnums.judgementEnum.OKEARLY:
			score += PerfectScore * 0.5 * scoreMult
			TScore += PerfectScore * 0.5
		GlobalEnums.judgementEnum.GOODLATE, GlobalEnums.judgementEnum.GOODEARLY:
			score += PerfectScore * 0.75 * scoreMult
			TScore += PerfectScore * 0.75
		GlobalEnums.judgementEnum.PERFECTLATE, GlobalEnums.judgementEnum.PERFECTEARLY:
			score += PerfectScore * 0.9 * scoreMult
			TScore += PerfectScore * 0.9
		GlobalEnums.judgementEnum.PERFECT:
			score += PerfectScore * scoreMult
			TScore += PerfectScore
	
	results.score += score
	results.techScore += TScore
	
	scoreUpdate.emit(results.score)

func updateCombo(isBroken : bool):
	if isBroken:
		combo = 0
		comboLabel.text = str(combo) + " COMBO!"
		scoreMult = 1
		return
	
	combo += 1
	
	if combo < GlobalStates.twoXBoundary:
		pass
	elif combo < GlobalStates.threeXBoundary:
		scoreMult = 2
	elif combo < GlobalStates.fourXBoundary:
		scoreMult = 3
	else:
		scoreMult = 4
	
	numOfHitNotes += 1
	
	if combo>results.maxCombo:
		results.maxCombo = combo
	
	comboLabel.text = str(combo) + " COMBO! " + str(scoreMult) + "x"

func _onMiss(trackIndex: int, noteIndex: int) -> void:
	updateCombo(true)
	updateScore(GlobalEnums.judgementEnum.MISS)
	#print("MISS! " + str(trackIndex) + ", " + str(noteIndex))

func _onNoteHit(judgement: int, offset: float, trackIndex: int, noteIndex: int) -> void:
	updateCombo(false)
	updateScore(judgement)


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
	updateCombo(false)
	updateScore(judgement)


func _onChartEnded():
	
	print(results.calculateGrade(maxWScore))
	
	SceneManager.loadResultsScreen(results)
