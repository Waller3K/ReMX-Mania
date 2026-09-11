@tool
extends Panel

# References to all relevent input fields in the panel!
@export var LoadChartButton : Button
@export var NewChartButton : Button
@export var SaveChartButton : Button
@export var CloseChartButton : Button
@export var EditorFD : EditorFileDialog

# Metadata fields
@export var SongTitleEdit : LineEdit
@export var SongTitleRomanEdit : LineEdit
@export var ArtistNameEdit : LineEdit
@export var ArtistNameRomanEdit : LineEdit
@export var CharterEdit : LineEdit
@export var DifficultyNameEdit : LineEdit
@export var DifficultyConstantBox : SpinBox
@export var StartingBPMBox : SpinBox
@export var PreviewTimestampBox : SpinBox
@export var TrackCountBox : SpinBox
@export var BGMPathEdit : LineEdit
@export var ScratchPathEdit : LineEdit
@export var Track1PathEdit : LineEdit
@export var Track2PathEdit : LineEdit
@export var Track3PathEdit : LineEdit
@export var Track4PathEdit : LineEdit



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect Button Signals
	LoadChartButton.pressed.connect(_onLoadChart)
	NewChartButton.pressed.connect(_onNewChart)
	SaveChartButton.pressed.connect(_onSaveChart)
	CloseChartButton.pressed.connect(_onCloseChart)
	
	# Connecting input fields
	# Text fields
	SongTitleEdit.text_submitted.connect(_onMetadataTextChanged.bind("songName"))
	SongTitleEdit.text_changed.connect(needsRomanization.bind(SongTitleRomanEdit))
	
	SongTitleRomanEdit.text_submitted.connect(_onMetadataTextChanged.bind("songNameRom"))
	SongTitleRomanEdit.text_changed.connect(isRomanized.bind(SongTitleRomanEdit))
	
	ArtistNameEdit.text_submitted.connect(_onMetadataTextChanged.bind("songArtist"))
	ArtistNameEdit.text_changed.connect(needsRomanization.bind(ArtistNameRomanEdit))
	
	ArtistNameRomanEdit.text_submitted.connect(_onMetadataTextChanged.bind("songArtistRom"))
	ArtistNameRomanEdit.text_changed.connect(isRomanized.bind(ArtistNameRomanEdit))
	
	CharterEdit.text_submitted.connect(_onMetadataTextChanged.bind("charter"))
	DifficultyNameEdit.text_submitted.connect(_onMetadataTextChanged.bind("difficultyName"))
	# Spinboxes
	DifficultyConstantBox.value_changed.connect(_onMetadataValueChanged.bind("difficulty"))
	StartingBPMBox.value_changed.connect(_onMetadataValueChanged.bind("bpm"))
	PreviewTimestampBox.value_changed.connect(_onMetadataValueChanged.bind("previewTimestamp"))
	TrackCountBox.value_changed.connect(_onMetadataValueChanged.bind("trackCount"))
	# Path Edits
	BGMPathEdit.text_submitted.connect(_onMetadataTextChanged.bind("BGMPath"))
	ScratchPathEdit.text_submitted.connect(_onMetadataTextChanged.bind("scratchTrackPath"))
	Track1PathEdit.text_submitted.connect(_onMetadataTextChanged.bind("trackPaths", 0))
	Track2PathEdit.text_submitted.connect(_onMetadataTextChanged.bind("trackPaths", 1))
	Track3PathEdit.text_submitted.connect(_onMetadataTextChanged.bind("trackPaths", 2))
	Track4PathEdit.text_submitted.connect(_onMetadataTextChanged.bind("trackPaths", 3))
	

## Checks if the input is still ASCII and deletes the most recent character if not.
func isRomanized(text : String, lineEdit : LineEdit):
	if ReMXEditor.isASCII(text):
		return
	
	lineEdit.delete_char_at_caret()
	lineEdit.caret_column = lineEdit.text.length()

## Checks if the text needs romanization and enables the romanized line edit if true!
func needsRomanization(text : String, romanizedLineEdit : LineEdit):
	if ReMXEditor.isASCII(text):
		if romanizedLineEdit.visible:
			romanizedLineEdit.clear()
			romanizedLineEdit.text_submitted.emit()
			romanizedLineEdit.visible = false
		return
	
	romanizedLineEdit.visible = true

## Takes the currentChart from the ReMXEditor class and sets
## all of the UI Fields to the corrisponding values!
func setChartMetadata():
	SongTitleEdit.text = ReMXEditor.currentChart.songName
	if !ReMXEditor.isASCII(ReMXEditor.currentChart.songName):
		SongTitleRomanEdit.visible = true
		SongTitleRomanEdit.text = ReMXEditor.currentChart.songNameRom
	ArtistNameEdit.text = ReMXEditor.currentChart.songArtist
	if !ReMXEditor.isASCII(ReMXEditor.currentChart.songArtist):
		ArtistNameRomanEdit.visible = true
		ArtistNameRomanEdit.text = ReMXEditor.currentChart.songArtistRom
	CharterEdit.text = ReMXEditor.currentChart.charter
	DifficultyNameEdit.text = ReMXEditor.currentChart.difficultyName
	DifficultyConstantBox.value = ReMXEditor.currentChart.difficulty
	StartingBPMBox.value = ReMXEditor.currentChart.bpm
	PreviewTimestampBox.value = ReMXEditor.currentChart.previewTimestamp
	TrackCountBox.value = ReMXEditor.currentChart.trackCount
	BGMPathEdit.text = ReMXEditor.currentChart.BGMPath
	ScratchPathEdit.text = ReMXEditor.currentChart.scratchTrackPath
	Track1PathEdit.text = ReMXEditor.currentChart.trackPaths[0]
	Track2PathEdit.text = ReMXEditor.currentChart.trackPaths[1]
	Track3PathEdit.text = ReMXEditor.currentChart.trackPaths[2]
	Track4PathEdit.text = ReMXEditor.currentChart.trackPaths[3]

## Clears all of the data in the UI fields!
func clearChartMetadata():
	SongTitleEdit.text = ""
	if SongTitleRomanEdit.visible:
		SongTitleRomanEdit.text = ""
		SongTitleRomanEdit.visible = false
	ArtistNameEdit.text = ""
	if ArtistNameRomanEdit.visible:
		ArtistNameRomanEdit.text = ""
		ArtistNameRomanEdit.visible = false
	CharterEdit.text = ""
	DifficultyNameEdit.text = ""
	DifficultyConstantBox.value = 0
	StartingBPMBox.value = 0
	PreviewTimestampBox.value = 0
	TrackCountBox.value = 2
	BGMPathEdit.text = ""
	ScratchPathEdit.text = ""
	Track1PathEdit.text = ""
	Track2PathEdit.text = ""
	Track3PathEdit.text = ""
	Track4PathEdit.text = ""

func _onMetadataTextChanged(newText : String, property : String, index : int = 0):
	if property not in ReMXEditor.currentChart:
		push_error(" Error! There is no '", property, "' in Chart!")
		return
	
	if property == "trackPaths":
		ReMXEditor.currentChart.trackPaths[index] = newText
		return
	
	ReMXEditor.currentChart.set(property, newText)

func _onMetadataValueChanged(newValue : float, property : String):
	if property not in ReMXEditor.currentChart:
		push_error(" Error! There is no '", property, "' in Chart!")
		return
	
	ReMXEditor.currentChart.set(property, newValue)

func _onNewChart():
	pass

func _onLoadChart():
	EditorFD.file_mode = EditorFD.FileMode.FILE_MODE_OPEN_FILE
	EditorFD.title = "Load Chart"
	EditorFD.visible = true
	var chartPath = await EditorFD.file_selected
	var loadedChart : Chart = Chart.new()
	if !loadedChart.load(chartPath):
		push_error("Could not load chart at path: ", chartPath)
		return
	
	ReMXEditor.currentChart = loadedChart
	setChartMetadata()

func _onSaveChart():
	EditorFD.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	EditorFD.title = "Select Chart Directory"
	EditorFD.visible = true
	var chartDir = await EditorFD.dir_selected
	ReMXEditor.currentChart.save(chartDir)

func _onCloseChart():
	# Do nothing if there is no current chart
	if !ReMXEditor.currentChart:
		return
	
	ReMXEditor.currentChart = null
	clearChartMetadata()
