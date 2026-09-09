@tool
extends Panel

# References to all relevent input fields in the panel!
@export var LoadChartButton : Button
@export var NewChartButton : Button
@export var SaveChartButton : Button
@export var CloseChartButton : Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _onNewChart():
	pass

func _onOpenChart():
	pass

func _onSaveChart():
	pass

func _onCloseChart():
	pass
