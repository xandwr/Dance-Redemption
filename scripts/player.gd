extends CharacterBody2D


@export_category("Player Settings")
@export var WALK_SPEED : float = 100
@export var SPRINT_SPEED : float = 200


@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var area_2d = $Area2D


var start_dir = Vector2(0, 1)
var input_dir = Vector2.ZERO
var cur_speed = WALK_SPEED
var can_move = true;


func _ready():
	update_animation_parameters(start_dir)
	

func _process(_delta):
	if can_move:
		process_move()
	else:
		input_dir = Vector2.ZERO
		cur_speed = 0
	
	# update velocity all the time to prevent moving while frozen
	velocity = input_dir * cur_speed
	move_and_slide()
	
	update_animation_parameters(input_dir)
	pick_anim_state()
	
	
func process_move():
	input_dir = Vector2(
		(int)(Input.is_action_pressed("right")) - (int)(Input.is_action_pressed("left")),
		(int)(Input.is_action_pressed("down")) - (int)(Input.is_action_pressed("up"))
		).normalized()
		
	if Input.is_action_pressed("sprint"):
		cur_speed = SPRINT_SPEED
	else:
		cur_speed = WALK_SPEED
	
	
func update_animation_parameters(move_input : Vector2):
	if (move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)


func pick_anim_state():
	if (velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")
