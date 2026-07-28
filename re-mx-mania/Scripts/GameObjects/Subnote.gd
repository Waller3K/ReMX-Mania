extends Node3D

@export var scratchSprites : Array[CompressedTexture2D] = [null, null, null]

var isActive : bool = false

var startingPosition : float

var judgementLinePos : float

var hitTime : float = -1.0

var releaseTime : float = -1.0

var noteIndex : int = -1

var subnoteIndex : int = -1

var noteType : int = -1

var isHold : bool = false

func activate(NoteIndex : int, SubnoteIndex: int, NoteType: int, startingPos : float, hTime: float, holdEnd: float = -1.0):
	global_position.x = GlobalStates.mainTrackXPos[GlobalEnums.trackIDs.SCRATCH_TRACK]
	startingPosition = startingPos
	global_position.z = startingPosition
	global_position.y = 0.03
	hitTime = hTime
	noteIndex = NoteIndex
	subnoteIndex = SubnoteIndex
	visible = true
	isActive = true
	noteType = NoteType
	
	var sprite := get_node("Sprite3D") as Sprite3D
	
	sprite.texture = scratchSprites[noteType]
	
	if holdEnd != -1.0:
		isHold = true
		releaseTime = holdEnd

func deactivate():
	visible = false
	global_position = Vector3(0.0, 0.0, 0.0)
	noteIndex = -1
	subnoteIndex = -1
	noteType = -1
	hitTime = -1.0
	releaseTime = -1.0
	isHold = false
	isActive = false
	var sprite := get_node("Sprite3D") as Sprite3D
	sprite.texture = null

func update(songPos : float):
	if isActive:
		var relativeTime = hitTime - songPos
		global_position.z = judgementLinePos + (relativeTime * (GlobalStates.scrollSpd * 10))
	else:
		pass
