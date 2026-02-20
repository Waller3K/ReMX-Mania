extends Node2D

var scaleTimer = 0

func _ready() -> void:
	$Sprite2D.position = Vector2(get_window().size.x/2, get_window().size.y/2)
	pass

func _process(delta: float) -> void:
	if scaleTimer > 0:
		scaleTimer -= 1
		return
	$Sprite2D.scale = Vector2(1, 1)

func _on_main_note_play() -> void:
	$Sprite2D.scale = Vector2(1.5, 1.5)
	scaleTimer = 10
