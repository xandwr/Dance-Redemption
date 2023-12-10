extends Area2D


@onready var hit_label_container = $HitLabelContainer
@onready var hit_label = $HitLabelContainer/HitLabel
@onready var note_timer = $NoteTimer
@onready var delete_timer = $DeleteTimer


const TARGET_Y = 640
const SPAWN_Y = -16
const DISTANCE_TO_TARGET = TARGET_Y - SPAWN_Y


const LEFT_LANE_SPAWN = Vector2(640 - 192, SPAWN_Y)
const DOWN_LANE_SPAWN = Vector2(640 - 64, SPAWN_Y)
const UP_LANE_SPAWN = Vector2(640 + 64, SPAWN_Y)
const RIGHT_LANE_SPAWN = Vector2(640 + 192, SPAWN_Y)


var speed = 0
var hit = false
var move_label = false
var destroyed = false


func _process(delta):
	if !hit && !destroyed:
		position.y += speed * delta
	if destroyed:
		delete_timer.start()
	if move_label:
		hit_label_container.position.y -= speed / 4.0 * delta


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
	note_timer.start()
	move_label = true
	if score == 3: # perfect
		hit_label.text = "PERFECT!"
		hit_label.add_theme_color_override("font_color", Color("03bcff"))
		hit = true
	elif score == 2: # great
		hit_label.text = "GREAT"
		hit_label.add_theme_color_override("font_color", Color("26e815"))
		hit = true
	elif score == 1: # okay
		hit_label.text = "OKAY"
		hit_label.add_theme_color_override("font_color", Color("eeff00"))
		hit = true
	elif score == 0: # miss
		hit_label.text = "MISS"
		hit_label.add_theme_color_override("font_color", Color("red"))
		destroyed = true


func _on_note_timer_timeout():
	queue_free()


func _on_delete_timer_timeout():
	queue_free()
	get_parent().reset_combo()
