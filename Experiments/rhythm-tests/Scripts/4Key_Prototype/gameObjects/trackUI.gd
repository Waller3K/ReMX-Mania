extends HBoxContainer

# The color rects for each track
@export var trackUIElems : = []

# The colors
@export var inactiveColor : Color
@export var activeColor : Color

func _ready() -> void:
	for child in get_children():
		trackUIElems.append(child)
		child.color = inactiveColor


func _onBTN1(_inputTimestamp: float, isDown: bool) -> void:
	if isDown:
		trackUIElems[0].color = activeColor
	else:
		trackUIElems[0].color = inactiveColor


func _onBTN2(_inputTimestamp: float, isDown: bool) -> void:
	if isDown:
		trackUIElems[1].color = activeColor
	else:
		trackUIElems[1].color = inactiveColor


func _onBTN3(_inputTimestamp: float, isDown: bool) -> void:
	if isDown:
		trackUIElems[2].color = activeColor
	else:
		trackUIElems[2].color = inactiveColor


func _onBTN4(_inputTimestamp: float, isDown: bool) -> void:
	if isDown:
		trackUIElems[3].color = activeColor
	else:
		trackUIElems[3].color = inactiveColor
