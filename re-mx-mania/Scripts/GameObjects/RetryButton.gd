extends Button

func _onPressed() -> void:
	SceneManager.loadChartPlayer(GlobalStates.currentChartData)
