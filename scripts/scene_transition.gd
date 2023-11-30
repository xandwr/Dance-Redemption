extends CanvasLayer

func change_scene(target: String) -> void:
	$AnimationPlayer.play("fade_in")
	$DoorEnterSound.play()
	await $AnimationPlayer.animation_finished
	$DoorExitSound.play()
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play_backwards("fade_in")
