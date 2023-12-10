extends Node2D


var perfect = false
var great = false
var okay = false
var current_note = null


@export var input = ""


func _process(_delta):
	if Input.is_action_just_pressed(input, false):
		var manager = get_parent().get_parent().get_parent()
		if current_note != null:
			if perfect:
				manager.increment_score(3)
				current_note.destroy(3)
			elif great:
				manager.increment_score(2)
				current_note.destroy(2)
			elif okay:
				manager.increment_score(1)
				current_note.destroy(1)
			_reset()
		else:
			manager.increment_score(0)
	if Input.is_action_just_pressed(input):
		get_node("AnimatedSprite2D").frame = 1
	elif Input.is_action_just_released(input):
		get_node("AnimatedSprite2D").frame = 0


func _on_perfect_area_area_entered(area):
	if area.is_in_group("note"):
		perfect = true


func _on_perfect_area_area_exited(area):
	if area.is_in_group("note"):
		perfect = false


func _on_great_area_area_entered(area):
	if area.is_in_group("note"):
		great = true


func _on_great_area_area_exited(area):
	if area.is_in_group("note"):
		great = false


func _on_okay_area_area_entered(area):
	if area.is_in_group("note"):
		okay = true
		current_note = area


func _on_okay_area_area_exited(area):
	if area.is_in_group("note") and area.hit == false:
		okay = false
		area.destroy(0)
		get_parent().get_parent().get_parent().missed += 1
		get_parent().get_parent().get_parent().reset_combo()
		current_note = null


func _reset():
	current_note = null
	perfect = false
	great = false
	okay = false
