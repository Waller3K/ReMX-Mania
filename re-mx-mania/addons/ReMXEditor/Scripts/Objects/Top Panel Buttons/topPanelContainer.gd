@tool
extends HBoxContainer


@export var snappingToggle : Button
@export var gridLevelLabel : Label
@export var gridLevelBox : SpinBox
@export var testAddNoteButton : Button

func _ready() -> void:
	snappingToggle.toggled.connect(toggleSnapping)
	gridLevelBox.value_changed.connect(_onGridLevelChanged)
	testAddNoteButton.pressed.connect(_onTestAddNotePressed)
	
	gridLevelBox.visible = false
	gridLevelLabel.visible = false
	snappingToggle.disabled = true
	testAddNoteButton.disabled = true




func toggleSnapping(state: bool) -> void:
	pass

func _onGridLevelChanged(newGridLevel : int) -> void:
	ReMXEditor.gridSnap = newGridLevel

func _onTestAddNotePressed() -> void:
	ReMXEditor.currentChart.addMainNote(2, ReMXEditor.chartPos)
	


func _onChartLoadedInEditor() -> void:
	snappingToggle.disabled = false
	testAddNoteButton.disabled = false


func _onChartClosed() -> void:
	snappingToggle.disabled = true
	testAddNoteButton.disabled = true
