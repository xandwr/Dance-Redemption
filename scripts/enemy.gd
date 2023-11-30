extends CharacterBody2D


@export_category("Enemy Settings")
@export var CHASE_SPEED : float = 80
@export var navigation_agent: NavigationAgent2D


@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")


var start_dir = Vector2(0, 1)
var target_node = null
var home_position = Vector2.ZERO
var can_move = true;


func _ready():
	home_position = self.global_position
	update_animation_parameters(start_dir)
	navigation_agent.set_path_desired_distance(4.0)
	navigation_agent.set_target_desired_distance(4.0)
	
	
func _process(_delta):
	# using a binary vector here to mimic user input
	update_animation_parameters(velocity.normalized().round())
	pick_anim_state()


func _physics_process(_delta):	
	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	if (self.can_move):
		var axis = to_local(navigation_agent.get_next_path_position()).normalized()
		velocity = axis * CHASE_SPEED
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()


func recalc_path():
	if target_node:
		navigation_agent.target_position = target_node.global_position
	else:
		navigation_agent.target_position = home_position
	

func _on_recalculate_timer_timeout():
	recalc_path()
	
	
func update_animation_parameters(move_input : Vector2):
	if (move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)


func pick_anim_state():
	if (velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")


func begin_battle(target):
	# Enemy battle handler goes here
	print("Battle Start");
	target.can_move = false;
	self.can_move = false;
	SceneTransition.change_scene("res://scenes/scn_battle.tscn")


# using custom collision layers on the player and enemy objects 
# to automatically handle filtering
func _on_aggression_range_body_entered(body):
	target_node = body


func _on_de_aggro_range_body_exited(body):
	if body == target_node:
		target_node = null


func _on_battle_range_body_entered(body):
	if body == target_node:
		begin_battle(body)
