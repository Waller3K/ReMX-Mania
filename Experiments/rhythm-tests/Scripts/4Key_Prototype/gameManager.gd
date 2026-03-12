extends Node

signal startSong(songStartTime: float)

signal noteHit(track: int, note: int)

@export var combo : int = 0
@export var maxCombo : int = 0

@export var score : int = 0

@export var accuracy : float = 0.0

@export var scoreText : RichTextLabel

@export var comboText : RichTextLabel

@export var hitText : RichTextLabel

var numOfNotes :  int = 0

var perfScorePerNote : float = 0.0

const MAXSCORE : float = 1000000.0

#################################################
# When the chart is created this function plays 
# a metronome for 4 beats before starting the song
#################################################
func _onChartCreation(chart: Chart) -> void:
	for key in chart.notes:
		var val = chart.notes[key]
		numOfNotes += val.size()
	
	perfScorePerNote = MAXSCORE / numOfNotes
	
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
	startSong.emit(Time.get_ticks_msec())

####################################
# This function updates the combo,
# score, and accuracy of the player
# based on their judgements.
####################################
func updateScore(judgement: int) -> void:
	match judgement:
		GE.judgementEnum.OKLATE, GE.judgementEnum.OKEARLY:
			if combo > maxCombo:
				maxCombo = combo
			combo = 0
			@warning_ignore("narrowing_conversion")
			score += perfScorePerNote * 0.5
			hitText.text = "OK"
			hitText.push_color(Color(0.5,0.1,0.5))
			
		GE.judgementEnum.GOODLATE, GE.judgementEnum.GOODEARLY:
			combo += 1
			if combo > maxCombo:
				maxCombo = combo
			@warning_ignore("narrowing_conversion")
			score += perfScorePerNote * 0.75
			hitText.text = "Good"
			hitText.push_color(Color(0.5,0.1,0.5))
		GE.judgementEnum.PERFECTLATE, GE.judgementEnum.PERFECTEARLY:
			combo += 1
			if combo > maxCombo:
				maxCombo = combo
			@warning_ignore("narrowing_conversion")
			score += perfScorePerNote
			hitText.text = "Perfect"
			hitText.push_color(Color(0.5,0.1,0.5))
		GE.judgementEnum.PERFECT:
			combo += 1
			if combo > maxCombo:
				maxCombo = combo
			@warning_ignore("narrowing_conversion")
			score += 1.125 * perfScorePerNote
			hitText.text = "PERFECT!"
			hitText.push_color(Color(0.5,0.1,0.5))
		GE.judgementEnum.MISS:
			if combo > maxCombo:
				maxCombo = combo
			combo = 0
			hitText.text = "MISS"
			hitText.push_color(Color(1,0.0,0.0))
	
	scoreText.text = "Score : " + str(score)
	comboText.text = "Combo! " + str(combo)

func _onGoodEarly(offset, trackIndex, noteIndex):
	print("Good Early! " + str(offset))
	noteHit.emit(trackIndex, noteIndex)
	updateScore(GE.judgementEnum.GOODEARLY)
	pass


func _onGoodLate(offset, trackIndex, noteIndex):
	print("Good Late! " + str(offset))
	noteHit.emit(trackIndex, noteIndex)
	updateScore(GE.judgementEnum.GOODLATE)
	pass


func _onMiss(trackIndex, noteIndex):
	print("Miss!") # Replace with function body.
	noteHit.emit(trackIndex, noteIndex)
	updateScore(GE.judgementEnum.MISS)
	pass


func _onOkEarly(offset, trackIndex, noteIndex):
	print("OK Early! " + str(offset)) # Replace with function body.
	noteHit.emit(trackIndex, noteIndex)
	updateScore(GE.judgementEnum.OKEARLY)
	pass


func _onOkLate(offset, trackIndex, noteIndex):
	print("OK Late! " + str(offset))
	noteHit.emit(trackIndex, noteIndex)
	updateScore(GE.judgementEnum.OKLATE)
	pass


func _onPerfect(offset, trackIndex, noteIndex):
	print("Perfect! " + str(offset))
	noteHit.emit(trackIndex, noteIndex)
	updateScore(GE.judgementEnum.PERFECT)
	pass


func _onPerfectEarly(offset, trackIndex, noteIndex):
	print("Perfect Early! " + str(offset))
	noteHit.emit(trackIndex, noteIndex)
	updateScore(GE.judgementEnum.PERFECTEARLY)
	pass


func _onPerfectLate(offset, trackIndex, noteIndex):
	print("Perfect Late! " + str(offset))
	noteHit.emit(trackIndex, noteIndex)
	updateScore(GE.judgementEnum.PERFECTLATE)
	pass
