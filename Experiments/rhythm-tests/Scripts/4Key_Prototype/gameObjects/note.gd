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
	
	if (endTargetTime != -1):
		# Creates the body of the hold note
		var noteBody: ColorRect = ColorRect.new()
		noteBody.color = Color(0.5,0.3,0.8)
		noteBody.size = self.size
		noteBody.position = Vector2(spawnPos.x, spawnPos.y)
		add_child(noteBody)
		noteBodyNode = noteBody

		# Creates the tail of the hold note
		var noteTail: TextureRect = TextureRect.new()
		noteTail.texture = self.texture
		noteTail.size = Vector2(self.size.x, self.size.y)
		noteTail.position = Vector2(spawnPos.x, spawnPos.y)
		add_child(noteTail)
		noteTailNode = noteTail

func getTrack() -> int:
	return trackID

func getNote() -> int:
	return noteID

func _onSongUpdate(timestamp: float):
	
	# Logic for note head

	var timeTillStart = targetTime - timestamp # The time until the start of the note
	var headT = clamp(1.0 - (timeTillStart / spawnOffset), 0.0, 1.0) # The scaler for the lerp
	var headY = lerp(spawnPos.y, judgementLinePos.y, headT)
	self.position.y = headY

	if (endTargetTime != -1):
		var timeTillEnd = endTargetTime - timestamp # The time until the end of the held note
		var tailT = clamp(1.0 - (timeTillEnd / spawnOffset), 0.0, 1.0) # The scaler for the lerp
		var tailY = lerp(spawnPos.y, judgementLinePos.y, tailT)
		noteTailNode.position.y = tailY - headY

		var bodyLength = headY - tailY
		noteBodyNode.position.y = tailY - headY 
		noteBodyNode.size = Vector2(self.size.x, bodyLength)
		print(bodyLength)