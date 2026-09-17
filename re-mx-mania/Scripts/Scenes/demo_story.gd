extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(_onDialogicSignal)
	Dialogic.start("classDemo")
	await Dialogic.timeline_ended
	SceneManager.loadMainMenu()

func _onDialogicSignal(args):
	if args is Dictionary:
		if !args.has("Arg"):
			push_error("Invalid Dictionary signal passed to Dialogic!")
			return
		
		if args["Arg"] == "LoadChart":
			if !args.has("Path"):
				push_error("'LoadChart' argument from Dialogic signal requires a 'Path' in the dictionary")
				return
			
			GlobalStates.currentChartData = Chart.new()
			if !GlobalStates.currentChartData.load(args["Path"]):
				push_error("Could not load path specified from Dialogic signal!")
				GlobalStates.currentChartData = null
		return
	
	# Args is a string
	if args == "StartChart":
		if GlobalStates.currentChartData != null:
			SceneManager.loadChartPlayer(GlobalStates.currentChartData)
			return
		
		push_error("No chart loaded into GlobalStates.currentChartData!")
