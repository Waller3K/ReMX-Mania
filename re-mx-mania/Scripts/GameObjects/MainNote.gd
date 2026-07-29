extends Node3D

@export var normalNoteMaterial : StandardMaterial3D
@export var FXNoteMaterial : StandardMaterial3D
@export var activeNoteMaterial : StandardMaterial3D
@export var missedNoteMaterial : StandardMaterial3D #Only for missed hold notes

var isActive : bool = false

# This bool is true only while this note is currently being held down
# (This will affect the color of the note)
var isHolding : bool = false

var startingPosition : float

var judgementLinePos : float

var mainTrackLength : float

var hitTime : float = -1.0

var releaseTime : float = -1.0

var trackID : int = -1

var noteIndex : int = -1

var isHold : bool = false

func activate(TrackID : int, NoteIndex : int, startingPos : float, hTime: float, holdEnd: float = -1.0):
	global_position.x = GlobalStates.mainTrackXPos[TrackID]
	startingPosition = startingPos
	global_position.z = startingPosition
	global_position.y = 0.02
	hitTime = hTime
	trackID = TrackID
	noteIndex = NoteIndex
	visible = true
	isActive = true
	
	if trackID == GlobalEnums.trackIDs.TRACKFX:
		var meshInstance := get_node("MeshInstance3D") as MeshInstance3D
		meshInstance.mesh = meshInstance.mesh.duplicate()
		meshInstance.mesh.size.x = mainTrackLength
		global_position.y = 0.015
		meshInstance.set_surface_override_material(0, FXNoteMaterial)
	elif trackID == GlobalEnums.trackIDs.SCRATCH_TRACK:
		var meshInstance := get_node("MeshInstance3D") as MeshInstance3D
		meshInstance.mesh = meshInstance.mesh.duplicate()
		meshInstance.set_surface_override_material(0, normalNoteMaterial)
		meshInstance.mesh.size.x = GlobalStates.scratchNoteWidth
	else:
		var meshInstance := get_node("MeshInstance3D") as MeshInstance3D
		meshInstance.set_surface_override_material(0, normalNoteMaterial)
		meshInstance.mesh.size.x = GlobalStates.mainNoteWidth
	
	if holdEnd != -1.0:
		isHold = true
		releaseTime = holdEnd
		

func holdHit():
	isHolding = true
	var meshInstance := get_node("MeshInstance3D") as MeshInstance3D
	meshInstance.set_surface_override_material(0, activeNoteMaterial)

func holdMissed():
	isHolding = false
	var meshInstance := get_node("MeshInstance3D") as MeshInstance3D
	meshInstance.set_surface_override_material(0, missedNoteMaterial)

func deactivate():
	visible = false
	global_position = Vector3(0.0, 0.0, 0.0)
	trackID = -1
	noteIndex = -1
	hitTime = -1.0
	releaseTime = -1.0
	isHold = false
	isActive = false
	var meshInstance := get_node("MeshInstance3D") as MeshInstance3D
	meshInstance.set_surface_override_material(0, null)

func update(songPos : float):
	if isActive:
		var relativeTime = hitTime - songPos
		global_position.z = judgementLinePos + (relativeTime * (GlobalStates.scrollSpd * 10))
		if isHold:
			var meshInstance : MeshInstance3D = get_child(0)
			meshInstance.mesh = meshInstance.mesh.duplicate()
			meshInstance.mesh.size.y = (judgementLinePos + ((releaseTime - songPos) * (GlobalStates.scrollSpd * 10))) - global_position.z
			global_position.z += meshInstance.mesh.size.y/2
	else:
		pass
