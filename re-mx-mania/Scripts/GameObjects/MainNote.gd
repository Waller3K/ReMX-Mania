extends Node3D

var isActive : bool = false

var startingPosition : float

var judgementLinePos : float

var mainTrackLength : float

var hitTime : float = -1.0

var releaseTime : float = -1.0

var trackID : int = -1

var noteIndex : int = -1

var isHold : bool = false

func activate(TrackID : int, NoteIndex : int, startingPos : float, hTime: float, holdEnd: float = -1.0):
	position.x = GlobalStates.mainTrackXPos[TrackID]
	startingPosition = startingPos
	position.z = startingPosition
	position.y = 1
	hitTime = hTime
	trackID = TrackID
	noteIndex = NoteIndex
	visible = true
	isActive = true
	
	if trackID == GlobalEnums.trackIDs.TRACKFX:
		var meshInstance : MeshInstance3D = get_child(0)
		meshInstance.mesh = meshInstance.mesh.duplicate()
		meshInstance.mesh.size.x = mainTrackLength
		position.y = 0.5
	
	if holdEnd != -1.0:
		isHold = true
		releaseTime = holdEnd
		

func deactivate():
	visible = false
	position = Vector3(0.0, 0.0, 0.0)
	trackID = -1
	noteIndex = -1
	hitTime = -1.0
	releaseTime = -1.0
	isHold = false
	isActive = false

func update(songPos : float):
	if isActive:
		var relativeTime = hitTime - songPos
		position.z = judgementLinePos + (relativeTime * (GlobalStates.scrollSpd * 10))
		if isHold:
			var meshInstance : MeshInstance3D = get_child(0)
			meshInstance.mesh = meshInstance.mesh.duplicate()
			meshInstance.mesh.size.y = (judgementLinePos + ((releaseTime - songPos) * (GlobalStates.scrollSpd * 10))) - position.z
			position.z += meshInstance.mesh.size.y/2
	else:
		pass
