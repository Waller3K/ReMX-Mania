extends VBoxContainer

@export var musicSlider : HSlider

@export var sfxSlider : HSlider

@export var offsetBox : SpinBox

@export var scrollSpeedBox : SpinBox

@export var returnButton : Button

func _ready():
	returnButton.pressed.connect(_onReturn)
	musicSlider.value = db_to_linear(GlobalStates.musicVolumeDB)
	sfxSlider.value = db_to_linear(GlobalStates.sfxVolumeDB)
	musicSlider.value_changed.connect(_onVolumeChange.bind(0))
	sfxSlider.value_changed.connect(_onVolumeChange.bind(1))
	
	

func _onVolumeChange(volume: float, index : int):
	match index:
		0:
			GlobalStates.musicVolumeDB = linear_to_db(volume)
		1:
			GlobalStates.sfxVolumeDB = linear_to_db(volume)
	
	print(volume)

func _onReturn():
	SceneManager.loadMainMenu()
