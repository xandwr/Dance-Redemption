extends Node2D


@onready var conductor := $Conductor
@onready var score_label := $MarginContainer/VBoxContainer/Score
@onready var combo_label := $MarginContainer/VBoxContainer/Combo
@onready var misses_label := $MarginContainer/VBoxContainer/Misses
@onready var player_position_node := $PlayerPosition
@onready var enemy_position_node := $EnemyPosition


var score = 0
var combo = 0
var max_combo = 0
var perfect = 0
var great = 0
var okay = 0
var missed = 0


var song_position = 0.0
var song_position_in_beats = 0
var last_spawned_beat = 0
var sec_per_beat = 0.0


var spawn_1_beat = 0
var spawn_2_beat = 0
var spawn_3_beat = 0
var spawn_4_beat = 0


var lane = 0
var rand = 0
var note = load("res://prefabs/note.tscn")
var instance


func _ready():
	randomize()
	conductor.play_from_beat(0, 0)
	sec_per_beat = 60.0 / conductor.bpm
	
	Global.player.scale = Vector2(10, 10)
	Global.player.position = player_position_node.position
	
	Global.current_enemy.scale = Vector2(10, 10)
	Global.current_enemy.position = enemy_position_node.position


func _process(_delta):
	misses_label.text = "Missed: " + str(missed)
	score_label.text = "Score: " + str(score)
	if combo > 0:
		combo_label.text = "Combo: " + str(combo)
		if combo > max_combo:
			max_combo = combo
	else:
		combo_label.text = "Combo: 0"


func end_battle():
	get_parent().get_parent().get_parent().animation_player.play("fade")
	await get_parent().get_parent().get_parent().animation_player.animation_finished
	
	get_parent().get_parent().get_node("level_1").visible = true
	var battle_node = get_parent().get_parent().get_node("level_battle")
	get_parent().get_parent().call_deferred("remove_child", battle_node)
	Global.battle_in_progress = false
	Global.player_can_dance = false
	Global.current_enemy.kill()
	Global.player.can_move = true
	Global.player.position = Global.player_last_coords
	Global.player.scale = Vector2(1, 1)
	Global.purified_souls += 1
	Global.player.battle_dir = Vector2(1, 0)
	get_parent().get_parent().get_parent().audio_player.play()
	get_parent().get_parent().get_parent().animation_player.play_backwards("fade")


func _spawn_notes(to_spawn):
	if to_spawn > 0:
		lane = randi() % 4
		instance = note.instantiate()
		instance.initialize(lane)
		add_child(instance)
	if to_spawn > 1:
		while rand == lane:
			rand = randi() % 4
		lane = rand
		instance = note.instantiate()
		instance.initialize(lane)
		add_child(instance)


func increment_score(by):
	if by > 0:
		combo += 1
	else:
		combo = 0
		
	if by == 3:
		perfect += 1
	elif by == 2:
		great += 1
	elif by == 1:
		okay += 1
		
	score += by * combo


func reset_combo():
	combo = 0
	combo_label.text = "Combo: 0"


func _on_conductor_measure(note_position):
	if note_position == 1:
		_spawn_notes(spawn_1_beat)
	elif note_position == 2:
		_spawn_notes(spawn_2_beat)
	elif note_position == 3:
		_spawn_notes(spawn_3_beat)
	elif note_position == 4:
		_spawn_notes(spawn_4_beat)


func _on_conductor_beat(note_position):
	song_position_in_beats = note_position
	if song_position_in_beats > 8:
		Global.player_can_dance = true
		spawn_1_beat = 1
		spawn_2_beat = 1
		spawn_3_beat = 1
		spawn_4_beat = 1
	if song_position_in_beats > 9:
		Global.enemy_can_dance = true
	if song_position_in_beats > 28:
		spawn_1_beat = 1
		spawn_2_beat = 1
		spawn_3_beat = 2
		spawn_4_beat = 1
	if song_position_in_beats > 52:
		spawn_1_beat = 2
		spawn_2_beat = 1
		spawn_3_beat = 2
		spawn_4_beat = 1
	if song_position_in_beats > 84:
		spawn_1_beat = 2
		spawn_2_beat = 1
		spawn_3_beat = 2
		spawn_4_beat = 2
