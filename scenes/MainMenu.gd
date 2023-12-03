extends Node2D

@export var mainScene : PackedScene

func _on_play_button_up():
	get_tree().change_scene_to_file(mainScene.resource_path)


func _on_quit_button_up():
	get_tree().quit()
