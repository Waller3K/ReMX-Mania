extends ColorRect
var windowRes: Vector2i

func _ready() -> void:
	windowRes = get_window().size
	
	self.position = Vector2(windowRes.x/2 - 500, windowRes.y - windowRes.y/8)
