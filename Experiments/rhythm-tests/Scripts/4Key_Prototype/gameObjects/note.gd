extends TextureRect

var targetTime: float
var endTargetTime: float
var trackID: int
var noteID: int
var spawnPos: Vector2i
var judgementLinePos: Vector2i
var timeTillHit: float
var t: float #Weight for lerping the note's position
var spawnOffset: float

var noteBodyNode: ColorRect = null
var noteTailNode: TextureRect = null

func INIT(track: int, note: int, target: float, sOffset: float, sp: Vector2i, judgeLnPos: Vector2i, endTarget: float = -1) -> void:
	targetTime = target
	endTargetTime = endTarget
	trackID = track
	noteID = note
	spawnPos = sp
	self.position = sp
	judgementLinePos =  judgeLnPos
	spawnOffset = sOffset

	var parent = self.get_parent()
	
	if (endTargetTime != -1):
		# Creates the body of the hold note
		var noteBody: ColorRect = ColorRect.new()
		noteBody.color = Color(0.5,0.3,0.8)
		noteBody.size = self.size
		noteBody.position = self.position
		parent.add_child(noteBody)
		noteBodyNode = noteBody

		# Creates the tail of the hold note
		var noteTail: TextureRect = TextureRect.new()
		noteTail.texture = self.texture
		noteTail.scale = self.scale
		noteTail.size = self.size
		noteTail.position = self.position
		parent.add_child(noteTail)
		noteTailNode = noteTail

func getTrack() -> int:
	return trackID

func getNote() -> int:
	return noteID

func _onSongUpdate(timestamp: float):
	
	# In Osu!Mania the way the note's position is calculated with this formula
	# y = hitPosition + (noteTime - currentTime) * scrollSpeed * scale
	# I'm gonna be stealing this bar for bar

	var headY = judgementLinePos.y - (targetTime - timestamp) * GlobalStates.scrollSpd * 100

	self.position.y = headY

	if (endTargetTime != -1):

		var tailY = judgementLinePos.y - (endTargetTime - timestamp) * GlobalStates.scrollSpd * 100
		
		# noteTailNode.position.y = tailY - headY
		noteTailNode.position = Vector2(self.position.x, tailY)

		var length = abs(tailY - headY)

		noteBodyNode.position = Vector2(self.position.x, noteTailNode.position.y)
		noteBodyNode.size.y = length
