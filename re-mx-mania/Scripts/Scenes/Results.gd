extends Control

var placeHolderLabel : Label = null

@export var resultLabels : Array[Label]

@export var gradeTextures : Array[Texture]

@export var gradeGraphic : TextureRect

enum labelEnum {
	SCORE_TEXT,
	TECH_SCORE_TEXT,
	COMBO_TEXT,
	BREAKDOWN_TEXT
}

func _ready() -> void:
	var results : Results = GlobalStates.currentResults
	
	resultLabels[labelEnum.SCORE_TEXT].set_text("Final Score: " + str(results.score))
	resultLabels[labelEnum.TECH_SCORE_TEXT].set_text("Tech Score: " + str(results.techScore))
	resultLabels[labelEnum.COMBO_TEXT].set_text("Max Combo: " + str(results.maxCombo))
	resultLabels[labelEnum.BREAKDOWN_TEXT].set_text(
		"Performance Breakdown: \n" + 
		"Miss: " + str(results.hitBreakdown[GlobalEnums.judgementEnum.MISS]) + "\n" +
		"Ok EARLY: " + str(results.hitBreakdown[GlobalEnums.judgementEnum.OKEARLY]) + "\n" +
		"Good EARLY: " + str(results.hitBreakdown[GlobalEnums.judgementEnum.GOODEARLY]) + "\n" +
		"Perfect EARLY: " + str(results.hitBreakdown[GlobalEnums.judgementEnum.PERFECTEARLY]) + "\n" +
		"PERFECT!: " + str(results.hitBreakdown[GlobalEnums.judgementEnum.PERFECT]) + "\n" +
		"Perfect LATE: " + str(results.hitBreakdown[GlobalEnums.judgementEnum.PERFECTLATE]) + "\n" +
		"Good LATE: " + str(results.hitBreakdown[GlobalEnums.judgementEnum.GOODLATE]) + "\n" +
		"Ok LATE: " + str(results.hitBreakdown[GlobalEnums.judgementEnum.OKLATE]) + "\n"  
	)
	gradeGraphic.texture = gradeTextures[results.grade]
