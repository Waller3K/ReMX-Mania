extends Node3D

@export var padding 		: float 	= 0.1

# The max amount of time a judgement texture will be shown (In seconds)
@export var coolDownLength : float = 1.0

var mainTrackNode : MeshInstance3D
var mainButtonNode : MeshInstance3D
var FXButtonNode : MeshInstance3D
var scratchTrackNode : MeshInstance3D

var trackDividerNodes: Array[MeshInstance3D]
var trackButtonsNodes: Array[MeshInstance3D]

func _onChartCreated(_chart: Chart) -> void:
	
	mainTrackNode = get_parent()
	mainButtonNode = get_node("MainButtonMesh_1")
	FXButtonNode = get_node("FXButtonMesh")
	scratchTrackNode = $"../../ScratchTrack"
	
	var trackDividerNodeOriginal = get_node("TrackDivider_1")

	var mainButtonMesh = mainButtonNode.mesh
	var mainTrackMesh = mainTrackNode.mesh
	var FXButtonMesh = FXButtonNode.mesh
	
	GlobalStates.mainTrackXPos[0] = FXButtonNode.global_position.x
	GlobalStates.mainTrackXPos[1] = scratchTrackNode.global_position.x
	
	# Setting up Main Button Meshes
	mainButtonMesh.size.x = (mainTrackMesh.size.x / GlobalStates.TRACK_COUNT) - padding
	var leftEdge = mainTrackNode.position.x + mainTrackMesh.size.x / 2
	mainButtonNode.position.x = leftEdge - (mainButtonMesh.size.x / 2) - (padding / 2)
	
	GlobalStates.mainTrackXPos[2] = mainButtonNode.global_position.x
	
	trackButtonsNodes.clear()
	trackButtonsNodes.append(mainButtonNode)
	
	trackDividerNodes.append(trackDividerNodeOriginal)
	
	for i in GlobalStates.TRACK_COUNT - 1:
		# Main Buttons
		var newButton: MeshInstance3D = mainButtonNode.duplicate()
		newButton.name = "MainButtonMesh_" + str(i + 2)
		
		newButton.mesh = newButton.mesh.duplicate()
		
		newButton.position.x = leftEdge - (mainButtonMesh.size.x / 2) - (padding / 2) - ((mainButtonMesh.size.x + padding) * (i+1))
		trackButtonsNodes.append(newButton)
		add_child(newButton)
		GlobalStates.mainTrackXPos[i+3] = newButton.global_position.x
		
		#Create Track Dividers
		var newDivider := trackDividerNodeOriginal.duplicate() as MeshInstance3D
		newDivider.name = "TrackDivider_" + str(i+2)
		trackDividerNodes.append(newDivider)
		add_child(newDivider)
	
	# Initialize Track Dividers
	for i in trackDividerNodes.size():
		var divider = trackDividerNodes[i]
		divider.global_position.x = GlobalStates.mainTrackXPos[i + 2]
	
	
	# Setting up FX Button Mesh
	FXButtonMesh.size.x = (mainTrackMesh.size.x)
	FXButtonNode.position.x = mainTrackNode.position.x
	FXButtonNode.position.z = mainButtonNode.position.z - (padding + mainButtonMesh.size.z)


func _onBTN_1(_inputTimestamp: float, isDown: bool) -> void:
	get_node("MainButtonMesh_1")._onBTN(isDown)


func _onBTN_2(_inputTimestamp: float, isDown: bool) -> void:
	get_node("MainButtonMesh_2")._onBTN(isDown)


func _onBTN_3(_inputTimestamp: float, isDown: bool) -> void:
	if GlobalStates.TRACK_COUNT > 2:
		get_node("MainButtonMesh_3")._onBTN(isDown)



func _onBTN_4(_inputTimestamp: float, isDown: bool) -> void:
	if GlobalStates.TRACK_COUNT > 3:
		get_node("MainButtonMesh_4")._onBTN(isDown)


func _onBTN_FX(_inputTimestamp: float, isDown: bool) -> void:
	get_node("FXButtonMesh")._onBTN(isDown)
