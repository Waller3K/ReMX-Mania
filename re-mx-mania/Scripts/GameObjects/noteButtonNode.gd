extends Node3D

@export var padding 		: float 	= 0.1

# The max amount of time a judgement texture will be shown (In seconds)
@export var coolDownLength : float = 1.0

var mainTrackNode : MeshInstance3D
var FXButtonNode : MeshInstance3D
var scratchTrackNode : MeshInstance3D

var trackDividerNodes: Array[MeshInstance3D]
var trackButtonsNodes: Array[MeshInstance3D]

func initTrackButtons() -> void:
	# Start with initializing the FX Button Mesh
	FXButtonNode.global_position.x = mainTrackNode.global_position.x
	FXButtonNode.global_position.z = trackButtonsNodes[0].position.z - trackButtonsNodes[0].mesh.size.z - padding
	
	var FXMesh := FXButtonNode.mesh as Mesh
	var MainTrackMesh := mainTrackNode.mesh as Mesh
	
	FXMesh.size.x = MainTrackMesh.size.x
	
	# Set global track X pos
	GlobalStates.mainTrackXPos[GlobalEnums.trackIDs.TRACKFX] = FXButtonNode.global_position.x
	
	# Main track Buttons
	var leftEdge = mainTrackNode.global_position.x + MainTrackMesh.size.x / 2
	
	for i in trackButtonsNodes.size():
		var button = trackButtonsNodes[i]
		button.mesh.size.x = (MainTrackMesh.size.x / GlobalStates.TRACK_COUNT) - padding
		button.global_position.x = leftEdge - (button.mesh.size.x/2) - ((button.mesh.size.x + padding) * i) 
		GlobalStates.mainTrackXPos[i + GlobalEnums.trackIDs.TRACK1] = button.global_position.x
	
	# Track Dividers
	var halfButtonSize = trackButtonsNodes[0].mesh.size.x/2
	
	for i in trackDividerNodes.size():
		var divider = trackDividerNodes[i]
		divider.mesh.size.x = padding
		divider.global_position.x = GlobalStates.mainTrackXPos[i + GlobalEnums.trackIDs.TRACK1] - halfButtonSize
		
		#Init global width floats
		GlobalStates.mainNoteWidth = trackButtonsNodes[0].mesh.size.x
		GlobalStates.scratchNoteWidth = scratchTrackNode.mesh.size.x

func _onChartCreated(_chart: Chart) -> void:
	# Get original nodes
	mainTrackNode 	= get_parent()
	FXButtonNode  	= get_node("FXButtonMesh")
	
	scratchTrackNode= get_node("../../ScratchTrack")
	GlobalStates.mainTrackXPos[GlobalEnums.trackIDs.SCRATCH_TRACK] = scratchTrackNode.global_position.x
	
	var mainButtonNode	:= get_node("MainButtonMesh_1") as MeshInstance3D
	var TrackDivider  	:= get_node("TrackDivider_1") as MeshInstance3D
	
	# Add them to their Arrays
	trackButtonsNodes.append(mainButtonNode)
	trackDividerNodes.append(TrackDivider)
	
	# Creates the rest of the buttons and tracks
	for i in GlobalStates.TRACK_COUNT - 1: # -1 because we already did the first one.
		var newButton := trackButtonsNodes[0].duplicate() as MeshInstance3D
		newButton.name = "MainButtonMesh_" + str(i+2)
		newButton.mesh = newButton.mesh.duplicate()
		trackButtonsNodes.append(newButton)
		add_child(newButton)
	
	for i in GlobalStates.TRACK_COUNT - 2:
		var newDivider := trackDividerNodes[0].duplicate() as MeshInstance3D
		newDivider.name = "TrackDivider_" + str(i+2)
		trackDividerNodes.append(newDivider)
		add_child(newDivider)
	
	initTrackButtons()


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
