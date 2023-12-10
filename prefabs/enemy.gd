extends CharacterBody2D


@export_category("Enemy Settings")
@export var CHASE_SPEED : float = 80


@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var dance_timer: Timer = $DanceTimer


var start_dir = Vector2(0, 1)
var input_dir = Vector2.ZERO
var battle_dir = Vector2(-1, 0)
var prev_battle_dir = Vector2.ZERO
var target_node = null
var home_position = Vector2.ZERO
var can_move = true;
var sec_per_beat = 0.0


func _ready():
	home_position = self.global_position
	update_animation_parameters(start_dir)
	navigation_agent.set_path_desired_distance(4.0)
	navigation_agent.set_target_desired_distance(4.0)


func _process(_delta):
	# using a binary vector here to mimic user input
	if !Global.battle_in_progress:
		input_dir = velocity.normalized().round()
		update_animation_parameters(input_dir)
		dance_timer.stop()
		
	if Global.current_enemy == self:
		if Global.battle_in_progress && !Global.enemy_can_dance:
			update_animation_parameters(battle_dir)
		
		if (get_parent().has_node("level_battle") && sec_per_beat == 0.0):
			sec_per_beat = get_parent().get_node("level_battle/BattleManager/Conductor").sec_per_beat
			dance_timer.wait_time = sec_per_beat
			
		if dance_timer.is_stopped() && Global.enemy_can_dance:
			dance_timer.start()
	
	pick_anim_state()
	
func _physics_process(_delta):	
	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	if (self.can_move && !Global.battle_in_progress):
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


func kill():
	queue_free()
	Global.current_enemy = null
	Global.enemy_can_dance = false


func pick_anim_state():
	if (velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")


func begin_battle(target: CharacterBody2D):
	Global.battle_in_progress = true
	self.can_move = false
	Global.current_enemy = self.duplicate()
	Global.player_last_coords = target.position
	Global.player.can_move = false;
	Global.player.battle_dir = Vector2(1, 0)
	get_parent().get_parent().get_parent().load_level("level_battle", false)
	await get_parent().get_parent().get_parent().animation_player.animation_finished
	queue_free()
	get_parent().get_parent().call_deferred("add_child", Global.current_enemy)
	get_parent().get_parent().get_node("level_1").visible = false
	get_parent().get_parent().get_parent().audio_player.stop()


# using custom collision layers on the player and enemy objects 
# to automatically handle filtering
func _on_aggression_range_body_entered(body):
	target_node = body


func _on_de_aggro_range_body_exited(body):
	if body == target_node:
		target_node = null


func _on_battle_range_body_entered(body):
	if body == target_node && !Global.battle_in_progress:
		begin_battle(body)


func _on_dance_timer_timeout():
	battle_dir = Vector2(randi_range(-1, 1), randi_range(-1, 1))
	if battle_dir == Vector2.ZERO:
		battle_dir = Vector2(randi_range(-1, 1), randi_range(-1, 1))
	if battle_dir == prev_battle_dir:
		battle_dir = -battle_dir
	update_animation_parameters(battle_dir)
	prev_battle_dir = battle_dir
