extends Node2D

# This is the script that will keep track of the song metadata, and position.
var BGTrackPath = "res://Assets/Music/180_Click_Track.ogg"
var ScratchTrackPath = "res://Assets/Scratch Track/ahh-fresh.mp3"

var BPM = 180.0
var songPos: float
var songSPB = 60.0/180.0
var songPosInBeats: float
var isScratching: bool = false
var scratchInput = 0
var mouseDelta: Vector2
var isCrossfaded: bool = false

var scratchPos: float

@onready var scratchPlayer = $ScratchAudioPlayer
@onready var BGPlayer = $BGAudioPlayer

func _ready():
	scratchPlayer.stream = load(ScratchTrackPath)
	BGPlayer.stream = load(BGTrackPath)
	BGPlayer.play()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	updateSongPos()
	scratchSyst()

func scratchSyst() -> void:
	# Store the Current and previous mouse pos in variables
	
	
	
	if isScratching: 
		if mouseDelta.y > 3:
			scratchInput = 1
		elif mouseDelta.y < -3:
			scratchInput = -1
		else:
			scratchInput = 0
	else:
		scratchInput = 0
	
	if isCrossfaded:
		scratchPlayer.volume_db = 0.0
	else:
		scratchPlayer.volume_db = -72.0
	
	match scratchInput:
		1:
			var newPos = scratchPos-(0.001*mouseDelta.y)
			if newPos <= 0:
				newPos = 0.0001
			scratchPlayer.seek(newPos)
		-1:
			scratchPlayer.pitch_scale = 2.0
		0:
			scratchPlayer.pitch_scale = 1.0


func updateSongPos() -> void:
	songPos = BGPlayer.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	songPosInBeats = songPos/songSPB
	
	if isScratching:
		scratchPos = scratchPlayer.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scratchButton"):
		scratchPlayer.play()
		isScratching = true
	
	if event.is_action_pressed("mainButton") or event.is_action_pressed("secondaryButton"):
		isCrossfaded = true
	
	
	if event.is_action_released("scratchButton"):
		scratchPlayer.stop()
		isScratching = false
	
	if event.is_action_released("mainButton") or event.is_action_released("secondaryButton"):
		isCrossfaded = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and isScratching:
		mouseDelta = event.relative
