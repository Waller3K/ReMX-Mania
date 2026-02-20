extends Node2D

#Variable Initialization
var metronomeClickPath = "res://Assets/SFX/Closed_Hat_1.ogg"
var songBPM: float
var songSPB: float #Seconds per Beat
var songPos: float #Song Position in Secs
var songPosInBeats: float
var chartPath = "res://Assets/Charts/Test.json"
var chartData: Dictionary
var chartHasEnded: bool = false
var nextNoteIndex = 0
@onready var audioStream = $AudioStreamPlayer
@onready var soundStream = $SoundStreamPlayer

#Signals
signal notePlay
signal notePerfect
signal noteEarly
signal noteLate
signal noteMiss

func _ready() -> void:
	audioStream.set_max_polyphony(10)
	chartData = loadChart(chartPath)
	audioStream.stream = load(chartData["SongData"]["Path"])
	songBPM = chartData["SongData"]["BPM"]
	songSPB = 60.0/songBPM
	audioStream.play()
	

func _process(_delta: float) -> void:
	updateSongPos()
	if !chartHasEnded:
		noteChecker()
	# print(songPosInBeats)

# Judgement and input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mainButton"):
		judge()

func updateSongPos() -> void:
	songPos = audioStream.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	songPosInBeats = songPos/songSPB

func noteChecker() -> void:
	if songPosInBeats >= chartData["Notes"][nextNoteIndex]["Time"]:
		notePlay.emit()
		if nextNoteIndex >= chartData["Notes"].size() - 1:
			print("End of Chart")
			chartHasEnded = true
			return
		nextNoteIndex += 1

func loadChart(path: String) -> Dictionary:
	# Open the path with read only access
	var fileStream = FileAccess.open(path, FileAccess.READ)
	# Check if path is valid
	assert(fileStream.file_exists(path), "File path is invalid!")
	
	var json = fileStream.get_as_text()
	var jsonObj = JSON.new()
	
	jsonObj.parse(json)
	
	return jsonObj.data

# Takes in the next note index from the chart
func judge() -> void:
	
	# Checks if there is a previous note to judge
	if nextNoteIndex == 0:
		# Convert next note pos to seconds
		var nextNotePos = chartData["Notes"][nextNoteIndex]["Time"]*songSPB
		
		# Check judgements
		if (nextNotePos - songPos) <= 0.0395:
			notePerfect.emit()
			return
			
		if (nextNotePos - songPos) <= 0.0725:
			noteEarly.emit()
			return
		
		# If both fail then the player missed
		noteMiss.emit()
		return
	
	# Convert next and previous note pos to seconds
	var nextNotePos = chartData["Notes"][nextNoteIndex]["Time"]*songSPB
	var prevNotePos = chartData["Notes"][nextNoteIndex-1]["Time"]*songSPB
	
	# Check judgements
	if (nextNotePos - songPos) <= 0.0395:
		notePerfect.emit()
		return
		
	if (nextNotePos - songPos) <= 0.0725:
		noteEarly.emit()
		return
	
	if (songPos - prevNotePos) <= 0.0395:
		notePerfect.emit()
		return
	
	if (songPos - prevNotePos) <= 0.0725:
		noteLate.emit()
		return
	
	# If both fail then the player missed
	noteMiss.emit()
	return

# Signal Functions
func _on_note_play() -> void:
	print("Note")
	soundStream.stream = load(metronomeClickPath)
	soundStream.play()
	


func _on_note_early() -> void:
	print("Early") # Replace with function body.


func _on_note_late() -> void:
	print("Late")  # Replace with function body.


func _on_note_miss() -> void:
	print("Miss!")  # Replace with function body.


func _on_note_perfect() -> void:
	print("Perfect!")  # Replace with function body.
