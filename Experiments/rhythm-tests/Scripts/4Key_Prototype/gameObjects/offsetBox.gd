extends SpinBox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Sets the value of the box to current global offset
	value = GlobalStates.globalOffset
	value_changed.connect(onValueChange)

func onValueChange(value: float) -> void:
	GlobalStates.globalOffset = value
