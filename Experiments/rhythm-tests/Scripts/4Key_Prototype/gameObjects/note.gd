extends Sprite2D

var targetTime: float
var trackID: int
var spawnPos: Vector2i
var judgementLinePos: Vector2i
var timeTillHit: float
var t: float #Weight for lerping the note's position
var spawnOffset: float

func INIT(target: float, sOffset: float, sp: Vector2i, judgeLnPos: Vector2i) -> void:
	targetTime = target
	#trackID = track
	spawnPos = sp
	self.position = sp
	judgementLinePos =  judgeLnPos
	spawnOffset = sOffset

func _onSongUpdate(timestamp: float):
	
	timeTillHit =  targetTime - timestamp
	
	t = 1.0 - (timeTillHit/spawnOffset)
	
	self.position.y = lerp(spawnPos.y, judgementLinePos.y, t)
	
