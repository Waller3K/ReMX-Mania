@tool
extends FoldableContainer

@export var tools : Array[Button]

signal toolChanged()

func _ready() -> void:
	folded = true
	
	var index : int = 0
	for toolButton in tools:
		toolButton.toggle_mode = true
		toolButton.toggled.connect(_onToolToggled.bind(index))
		if index == ReMXEditor.toolEnum.TAP:
			toolButton.button_pressed = true
		index += 1


## Called when a button is toggled and toggles the other buttons.
## This function also sets the current tool.
func _onToolToggled( state : bool, toolID : ReMXEditor.toolEnum):
	if state == true :
		var index : int = 0
		for toolButton in tools:
			if index == toolID:
				toolButton.disabled = true
				index += 1
				ReMXEditor.currentTool = toolID
				continue
			
			toolButton.button_pressed = false
			toolButton.disabled = false
			
			index += 1
		
		toolChanged.emit()
