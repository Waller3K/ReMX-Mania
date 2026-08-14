extends Button

@export var chartPath : String

func setPath(path : String) -> void:
	chartPath = path

func _onPressed():
	SceneManager.loadChartPlayer(chartPath)
