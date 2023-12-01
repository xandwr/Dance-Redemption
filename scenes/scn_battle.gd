extends Node2D

var score = 0
var combo = 0

var max_combo = 0
var perfect = 0
var great = 0
var okay = 0
var missed = 0

var bpm = 140

var song_position = 0.0
var song_position_in_beats = 0
var last_spawned_beat = 0
var sec_per_beat = 60.0 / bpm

var spawn_1_beat = 0
var spawn_2_beat = 0
var spawn_3_beat = 0
var spawn_4_beat = 0

var lane = 0
var rand = 0
var note = load("res://scenes/objects/note.tscn")
var instance

func _ready():
	randomize()
	$Conductor.play_from_beat(0, 0)
	
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
	else:
		missed += 1
		
	score += by * combo
	$Score.text = "Score: " + str(score)
	if combo > 0:
		$Combo.text = "Combo: " + str(combo)
		if combo > max_combo:
			max_combo = combo
	else:
		$Combo.text = "Combo: "
	

func reset_combo():
	combo = 0
	$Combo.text = "Combo: "


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
	if song_position_in_beats > 12:
		spawn_1_beat = 1
		spawn_2_beat = 1
		spawn_3_beat = 1
		spawn_4_beat = 1
	if song_position_in_beats > 28:
		spawn_1_beat = 2
		spawn_2_beat = 1
		spawn_3_beat = 1
		spawn_4_beat = 2
	if song_position_in_beats > 52:
		spawn_1_beat = 1
		spawn_2_beat = 1
		spawn_3_beat = 1
		spawn_4_beat = 1
	if song_position_in_beats > 84:
		spawn_1_beat = 2
		spawn_2_beat = 1
		spawn_3_beat = 2
		spawn_4_beat = 1
