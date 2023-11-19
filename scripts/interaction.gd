extends Area2D

var target_body = null

func _on_body_entered(body):
	if body.is_in_group("Interactable"):
		target_body = body

func _on_body_exited(body):
	if body.is_in_group("Interactable"):
		target_body = null

func _physics_process(_delta):
	if (target_body):
		if (Input.is_action_just_pressed("interact")):
			target_body.interact()
