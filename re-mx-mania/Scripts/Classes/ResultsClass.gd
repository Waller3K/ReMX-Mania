## A Class that stores player scoring info like final score, max combo, grade, etc.
class_name Results

extends Resource

## The current weighted score the player has recived
var score : int = 0

## The current technical score the player recived (No combo multiplier)
var techScore : int = 0

## The current highest combo the player has hit!
var maxCombo : int = 0

## The grade recived from the chart (From F to SSS+) has to be from GlobalEnums.GradeEnum
var grade : GlobalEnums.gradeEnum = GlobalEnums.gradeEnum.F

## An array containing the number of and types of hits the player did. Indexed with the judgement enum
var hitBreakdown : Array[int] = [0,0,0,0,0,0,0,0]

## A bool that is true if the player passed the chart and is false if the player failed
var isPassing : bool

## A function that takes in the maximum possible weighted score for a given chart, and 
## calculates the player's final grade based on what percentage of the notes were
## hit, whether or not the play was a full combo, and other factors 
func calculateGrade(maxWScore : int) -> GlobalEnums.gradeEnum:
	# If the play was a full combo
	if hitBreakdown[GlobalEnums.judgementEnum.MISS] == 0:
		var noAlmostPerfect : bool = (
			hitBreakdown[GlobalEnums.judgementEnum.PERFECTEARLY] == 0 and 
			hitBreakdown[GlobalEnums.judgementEnum.PERFECTLATE] == 0
		)
		var noGood : bool = (
			hitBreakdown[GlobalEnums.judgementEnum.GOODEARLY] == 0 and 
			hitBreakdown[GlobalEnums.judgementEnum.GOODLATE] == 0
		)
		var noOK : bool = (
			hitBreakdown[GlobalEnums.judgementEnum.OKEARLY] == 0 and 
			hitBreakdown[GlobalEnums.judgementEnum.OKLATE] == 0
		)
		# If it was a pure perfect full combo:
		if noAlmostPerfect and noGood and noOK:
			return GlobalEnums.gradeEnum.SSS_PLUS
		# If it was a perfect full combo:
		if noGood and noOK:
			return GlobalEnums.gradeEnum.SSS
		# If it was a good full combo:
		if noOK:
			return GlobalEnums.gradeEnum.SS
		# If it was just a regular full combo:
		return GlobalEnums.gradeEnum.S
	
	# If the play wasn't an FC:
	var scoreRatio : float = float(score) / float(maxWScore)
	
	grade = GlobalEnums.gradeEnum.F
	for gradeThreshold in GlobalStates.gradeThresholds:
		if scoreRatio < gradeThreshold:
			return grade
		grade += 1
	
	return grade
