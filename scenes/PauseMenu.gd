extends Node2D


func pause():
	get_tree().paused = true
	show()


func unpause():
	hide()
	get_tree().paused = false


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused == true:
			unpause()
		else:
			pause()


func _on_play_pressed():
	unpause()


func _on_quit_pressed():
	print("quit pressed")
	get_tree().quit()
