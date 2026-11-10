@tool
extends HBoxContainer


@export var snappingToggle : Button
@export var gridLevelLabel : Label
@export var gridLevelBox : SpinBox
@export var testAddNoteButton : Button

@export var visibleLengthBox : SpinBox

func _ready() -> void:
	snappingToggle.toggled.connect(toggleSnapping)
	gridLevelBox.value_changed.connect(_onGridLevelChanged)
	testAddNoteButton.pressed.connect(_onTestAddNotePressed)
	
	visibleLengthBox.value = ReMXEditor.visibleLength
	visibleLengthBox.value_changed.connect(_onVisibleLengthChange)
	
	# Set default values
	_onGridLevelChanged(1)
	toggleSnapping(false)
	
	gridLevelBox.visible = false
	gridLevelLabel.visible = false
	snappingToggle.disabled = true
	testAddNoteButton.disabled = true


func toggleSnapping(state: bool) -> void:
	ReMXEditor.isSnapping = state
	gridLevelBox.visible = state
	gridLevelLabel.visible = state

func _onGridLevelChanged(newGridLevel : int) -> void:
	ReMXEditor.gridSnap = newGridLevel

func _onTestAddNotePressed() -> void:
	ReMXEditor.currentChart.addMainNote(2, ReMXEditor.chartPos)
	

func _onVisibleLengthChange(newVisibleLength : float) -> void:
	ReMXEditor.visibleLength = newVisibleLength


func _onChartLoadedInEditor() -> void:
	snappingToggle.disabled = false
	testAddNoteButton.disabled = false


func _onChartClosed() -> void:
	snappingToggle.disabled = true
	testAddNoteButton.disabled = true
