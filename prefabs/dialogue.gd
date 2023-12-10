extends CanvasLayer


signal dialogue_finished


var scene_text = {}
var selected_text = []
var in_progress = false
var has_skipped = false


@onready var dialogue_label: Label = $MarginContainer/MarginContainer/ColorRect/MarginContainer/Label
@onready var text_timer: Timer = $TextTimer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready():
	visible = false
	scene_text = load_text()


func _process(_delta):
	Global.player_currently_in_dialogue = in_progress
	if Global.battle_in_progress:
		cleanup()


func load_text():
	var file = FileAccess.open("res://json/dialogue_options.json", FileAccess.READ)
	return JSON.parse_string(file.get_as_text())


func show_text():
	dialogue_label.visible_characters = 0
	dialogue_label.text = selected_text.pop_front()
	text_timer.start()


func next_line():
	has_skipped = false
	if selected_text.size() > 0:
		show_text()
	else:
		cleanup()


func cleanup():
	dialogue_label.text = ""
	dialogue_label.visible_characters = -1
	visible = false
	in_progress = false
	has_skipped = false
	Global.player_currently_in_dialogue = false
	text_timer.stop()
	emit_signal("dialogue_finished")


func display_dialogue(key: String):
	if in_progress:
		if dialogue_label.visible_characters == -1:
			next_line()
		elif dialogue_label.visible_characters < dialogue_label.text.length():
			has_skipped = true
			dialogue_label.visible_characters = -1
			text_timer.stop()
	else:
		visible = true
		in_progress = true
		selected_text = scene_text[key].duplicate()
		show_text()


func _on_text_timer_timeout():
	if dialogue_label.visible_characters < dialogue_label.text.length():
		dialogue_label.visible_characters += 1
		audio_player.play()
	else:
		dialogue_label.visible_characters = -1
		text_timer.stop()
