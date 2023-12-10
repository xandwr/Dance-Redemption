extends Node2D


var in_range: bool = false


func _input(_event):
	if in_range:
		if Input.is_action_just_pressed("interact"):
			get_parent().get_parent().get_parent().dialogue.display_dialogue("locked_door")


func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("Player"):
		in_range = true


func _on_area_2d_area_exited(area):
	if area.get_parent().is_in_group("Player"):
		in_range = false
