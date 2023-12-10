extends Node2D


@onready var chest_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var open_sound: AudioStreamPlayer = $Open
@onready var close_sound: AudioStreamPlayer = $Close


var in_range: bool = false
var is_open: bool = false


func _input(_event):
	if in_range:
		if Input.is_action_just_pressed("interact"):
			if !is_open:
				open_chest()
				
			get_parent().get_parent().get_parent().dialogue.display_dialogue("chest")


func _process(_delta):
	if is_open:
		await get_parent().get_parent().get_parent().dialogue.dialogue_finished
		close_chest()


func open_chest():
	chest_sprite.frame = 1
	open_sound.play()
	is_open = true


func close_chest():
	chest_sprite.frame = 0
	close_sound.play()
	is_open = false


func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("Player"):
		in_range = true


func _on_area_2d_area_exited(area):
	if area.get_parent().is_in_group("Player"):
		in_range = false
