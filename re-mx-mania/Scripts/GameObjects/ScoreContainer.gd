extends VBoxContainer

@export var scoreLabel : Label

## Helper function that takes in an integer string and outputs it with commas.
## So 1000000 becomes 1,000,000
func format_with_commas(value: int) -> String:
	var num_str: String = str(abs(value))
	var result: String = ""
	var num_length: int = num_str.length()
	
	for i in range(num_length):
		if i > 0 and (num_length - i) % 3 == 0:
			result += ","
		result += num_str[i]
		
	return ("-" + result) if value < 0 else result

func _ready() -> void:
	scoreLabel.text = "Score : 0"


func _onScoreUpdate(score: int) -> void:
	scoreLabel.text = "Score : " + format_with_commas(score)
