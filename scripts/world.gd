extends Node2D


signal level_changed(level_name)

@export var level_name = "placeholder_level_name"

var within_range = false


func _process(_delta):
	if within_range == true:
		if Input.is_action_just_pressed("interact"):
			var scene_name = "res://scenes/scn_level_" + str(int(level_name) + 1) + ".tscn"
			if ResourceLoader.exists(scene_name):
				SceneTransition.change_scene(scene_name)


func _on_door_area_entered(area):
	if (area.owner.is_in_group("Player")):
		within_range = true;


func _on_door_area_exited(area):
	if (area.owner.is_in_group("Player")):
		within_range = false;
