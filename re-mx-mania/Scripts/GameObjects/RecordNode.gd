extends MeshInstance3D

var isActive = false

func _process(delta : float) -> void:
	if !isActive:
		rotation.y += 5 * delta


func _onBTN_Scratch(_inputTimestamp: float, isDown: bool) -> void:
	isActive = isDown


func _onMouseMoved(_inputTimestamp: float, YVelocity: float) -> void:
	if isActive:
		rotation.y += YVelocity * 0.01
