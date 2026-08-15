extends Control

var chartButton = Button.new()
var isOpen : bool = false

func init(charts : Array[Chart]):
	for chart in charts:
		addDifficulty(chart)
	visible = false

func toggle():
	visible = !visible
	isOpen = !isOpen

## Returns whether or not the ChartList is open and active
func getIsOpen() -> bool:
	return isOpen

func openChart(chartData: Chart) -> void:
	SceneManager.loadChartPlayer(chartData)

func addDifficulty(chartData : Chart):
	var difficultyButton : Button = Button.new()
	difficultyButton.text = chartData.difficultyName
	difficultyButton.pressed.connect(openChart.bind(chartData))
	add_child(difficultyButton)
