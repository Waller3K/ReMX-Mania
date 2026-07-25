extends MeshInstance3D

######################################################
# This script is dynamically added to the buttons at 
# runtime and gives them visual feedback!
######################################################

func _onBTN(isDown : bool):
	if isDown:
		mesh.size.y = 0.3
	else:
		mesh.size.y = 1
