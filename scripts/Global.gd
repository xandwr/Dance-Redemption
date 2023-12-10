extends Node


var player: CharacterBody2D = load("res://prefabs/player.tscn").instantiate()
var player_spawn_coords: Vector2 = Vector2.ZERO
var player_last_coords: Vector2 = Vector2.ZERO
var player_can_dance: bool = false
var enemy_can_dance: bool = false
var current_enemy: CharacterBody2D = null
var current_level: String = ""
var battle_in_progress: bool = false
var player_currently_in_dialogue = false
var purified_souls: int = 0
