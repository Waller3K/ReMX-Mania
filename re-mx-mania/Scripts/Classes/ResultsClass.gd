## A Class that stores player scoring info like final score, max combo, grade, etc.
class_name Results

extends Resource

## The current score the player has recived
var score : int = 0

## The current highest combo the player has hit!
var maxCombo : int = 0

## The grade recived from the chart (From F to SSS+) has to be from GlobalEnums.GradeEnum
var grade : GlobalEnums.gradeEnum = GlobalEnums.gradeEnum.F

## An array containing the number of and types of hits the player did. Indexed with the judgement enum
var hitBreakdown : Array[int] = [0,0,0,0,0,0,0,0]
