extends Button

func _ready() -> void:
	pressed.connect(_onReturn)
	
func _onReturn() -> void:
	SceneManager.loadMainMenu()
