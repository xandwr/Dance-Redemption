extends Area2D

const TARGET_Y = 580
const SPAWN_Y = -16
const DISTANCE_TO_TARGET = TARGET_Y - SPAWN_Y

const LEFT_LANE_SPAWN = Vector2(642 - 178, SPAWN_Y)
const DOWN_LANE_SPAWN = Vector2(642 - 64, SPAWN_Y)
const UP_LANE_SPAWN = Vector2(642 + 64, SPAWN_Y)
const RIGHT_LANE_SPAWN = Vector2(642 + 178, SPAWN_Y)


var speed = 0
var hit = false
var move_label = false


func _process(delta):
	if !hit:
		position.y += speed * delta
		if position.y > 800:
			queue_free()
			get_parent().reset_combo()
	if move_label:
		$Node2D.position.y -= speed/4 * delta


func initialize(lane):
	if lane == 0:
		$AnimatedSprite2D.frame = 0
		position = LEFT_LANE_SPAWN
	elif lane == 1:
		$AnimatedSprite2D.frame = 1
		position = DOWN_LANE_SPAWN
	elif lane == 2:
		$AnimatedSprite2D.frame = 2
		position = UP_LANE_SPAWN
	elif lane == 3:
		$AnimatedSprite2D.frame = 3
		position = RIGHT_LANE_SPAWN
	else:
		printerr("Invalid lane set for note: " + str(lane))
		return
	
	speed = DISTANCE_TO_TARGET
	
	
func destroy(score):
	$AnimatedSprite2D.visible = false;
	$Timer.start()
	hit = true
	move_label = true
	if score == 3: # perfect
		$Node2D/Label.text = "PERFECT!"
		$Node2D/Label.modulate = Color("03bcff")
	elif score == 2: # great
		$Node2D/Label.text = "GREAT"
		$Node2D/Label.modulate = Color("26e815")
	elif score == 1: # okay
		$Node2D/Label.text = "OKAY"
		$Node2D/Label.modulate = Color("eeff00")
		

func _on_timer_timeout():
	queue_free()
