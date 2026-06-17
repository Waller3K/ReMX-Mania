extends Control



func _onSongSelectPressed():
	get_tree().change_scene_to_file("res://Scenes/Prototype_Build/Song_Select.tscn")


func _onOptionsPressed():
	get_tree().change_scene_to_file("res://Scenes/Prototype_Build/Options_Menu.tscn")


func _onQuitPressed():
	get_tree().quit()
