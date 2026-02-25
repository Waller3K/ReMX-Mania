extends Node



func _onGoodEarly(offset, trackIndex):
	print("Good Early! " + str(offset))


func _onGoodLate(offset, trackIndex):
	print("Good Late! " + str(offset))


func _onMiss(trackIndex):
	print("Miss!") # Replace with function body.


func _onOkEarly(offset, trackIndex):
	print("OK Early! " + str(offset)) # Replace with function body.


func _onOkLate(offset, trackIndex):
	print("OK Late! " + str(offset))


func _onPerfect(offset, trackIndex):
	print("Perfect! " + str(offset))


func _onPerfectEarly(offset, trackIndex):
	print("Perfect Early! " + str(offset))


func _onPerfectLate(offset, trackIndex):
	print("Perfect Late! " + str(offset))
