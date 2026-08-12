extends Sprite3D

# Order is the same as GlobalEnums.JudgementEnum
var judgementTextures : Array[CompressedTexture2D] = [
	load("res://Assets/Textures/Ok Judgement.png"), 			#OK LATE
	load("res://Assets/Textures/Good Judgement.png"), 			#Good LATE
	load("res://Assets/Textures/Almost Perfect Judgement.png"), #Almost Perfect LATE
	load("res://Assets/Textures/Perfect Judgement.png"), 		#Perfect!
	load("res://Assets/Textures/Almost Perfect Judgement.png"), #Almost Perfect EARLY
	load("res://Assets/Textures/Good Judgement.png"), 			#Good EARLY
	load("res://Assets/Textures/Ok Judgement.png"), 			#OK EARLY
	load("res://Assets/Textures/Miss Judgement.png") 			# Miss
]

@onready var timer : Timer = get_node_or_null("Timer")

# The length a judgement sprite stays active
@export var coolDown : float = 1.0

func _ready() -> void:
	timer.autostart = false
	timer.wait_time = coolDown
	timer.timeout.connect(onCoolDown)

func onCoolDown() -> void:
	texture = null

func setJudgement(judgement : int) -> void:
	texture = judgementTextures[judgement]
	timer.start(coolDown)

func _onMiss(trackIndex: int, noteIndex: int) -> void:
	setJudgement(GlobalEnums.judgementEnum.MISS)


func _onNoteHit(judgement: int, offset: float, trackIndex: int, noteIndex: int) -> void:
	setJudgement(judgement)


func _onHoldBroken(trackIndex: int, noteIndex: int, FX: int) -> void:
	setJudgement(GlobalEnums.judgementEnum.MISS)


func _onHoldTick(trackIndex: int, noteIndex: int) -> void:
	setJudgement(GlobalEnums.judgementEnum.PERFECT)


func _onScratchBreak(noteIndex: int, subnoteIndex: int) -> void:
	setJudgement(GlobalEnums.judgementEnum.MISS)
