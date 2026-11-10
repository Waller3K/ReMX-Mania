@tool
extends FoldableContainer

## The container that will hold the properties in the inspector
@export var vboxContainer : VBoxContainer

enum effectEnum {
	CHORUS,
	HIPASS,
	LOWPASS,
	PHASER,
	REVERB
}



func _ready() -> void:
	if is_part_of_edited_scene():
		return

func _onModeChanged(newMode : ReMXEditor.inspectorMode) -> void:
	clearChildren()
	
	ReMXEditor.currentIMode = newMode
	
	match newMode:
		ReMXEditor.inspectorMode.NONE:
			return
		ReMXEditor.inspectorMode.FX:
			var FXSpinboxContainer : HBoxContainer = HBoxContainer.new()
			var boxLabel : Label = Label.new()
			boxLabel.text = "FX Type"
			var spinbox : SpinBox = SpinBox.new()
			spinbox.step = 1
			spinbox.min_value = 0
			spinbox.max_value = effectEnum.size() - 1
			spinbox.value = effectEnum.CHORUS
			spinbox.value_changed.connect(_onFXValueChanged)
			
			FXSpinboxContainer.add_child(boxLabel)
			FXSpinboxContainer.add_spacer(false)
			FXSpinboxContainer.add_child(spinbox)
			
			vboxContainer.add_child(FXSpinboxContainer)
			
		ReMXEditor.inspectorMode.SCRATCH_SUBNOTE:
			pass
		_:
			return

func _onFXValueChanged(newValue):
	ReMXEditor.selectedFXType = newValue

## A simple helper function that takes clears the children from the 
## VBoxContainer
func clearChildren():
	for childNode : Node in vboxContainer.get_children():
		childNode.queue_free()


func _onToolChanged(toolID: ReMXEditor.toolEnum) -> void:
	match toolID:
		ReMXEditor.toolEnum.FX_HOLD:
			_onModeChanged(ReMXEditor.inspectorMode.FX)
		ReMXEditor.toolEnum.SUB_SCRATCH_SHORT, ReMXEditor.toolEnum.SUB_SCRATCH_LONG:
			_onModeChanged(ReMXEditor.inspectorMode.SCRATCH_SUBNOTE)
		_:
			_onModeChanged(ReMXEditor.inspectorMode.NONE)
