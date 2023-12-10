extends Control
## A persistent scene that follows the player across levels.

@onready var hud: CanvasLayer = $HUD
@onready var root_menu: CanvasLayer = $RootMenu
@onready var main_menu: Control = $RootMenu/MenuContainer/MainMenu
@onready var options_menu: Control = $RootMenu/MenuContainer/Options
@onready var pause_menu: Control = $RootMenu/MenuContainer/Pause
@onready var main_2d = $Main2D
@onready var camera = $Main2D/Camera2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var master_volume_slider: Slider = $RootMenu/MenuContainer/Options/VBoxContainer/SliderContainer/VBoxContainer/HSlider
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var dialogue: CanvasLayer = $Dialogue
@onready var purified_souls_label: Label = $HUD/MarginContainer/VBoxContainer/PurifiedLabel
var level_instance: Node2D


func _ready():
	options_menu.hide()
	pause_menu.hide()
	hud.hide()
	root_menu.show()
	main_menu.show()
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume_slider.value)
	play_audio("res://music/Background1.mp3")


func _process(_delta):	
	if Global.player:
		if !Global.battle_in_progress:
			camera.position = Vector2(
				Global.player.position.x - (get_viewport_rect().size.x / 2) / (camera.zoom.x), 
				Global.player.position.y - (get_viewport_rect().size.y / 2) / (camera.zoom.y)
			)
			camera.zoom = Vector2(3,3)
			if !root_menu.visible:
				hud.show()
		else:
			await animation_player.animation_finished
			purified_souls_label.text = "Souls Purified: " + str(Global.purified_souls)
			hud.hide()
			camera.position = Vector2(0,0)
			camera.zoom = Vector2(1,1)
	if AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) != master_volume_slider.value:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume_slider.value)


func _input(event):
	if event.is_action_pressed("pause"):
		root_menu.show()
		main_menu.hide()
		options_menu.hide()
		pause_menu.show()
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume_slider.value - 24.0)
		get_tree().paused = true
	if event.is_action_pressed("end_battle") && Global.battle_in_progress:
		var battle_manager = get_node("Main2D/level_battle/BattleManager")
		battle_manager.end_battle()


func play_audio(pathname: String):
	var file = FileAccess.open(pathname, FileAccess.READ)
	if file:
		var buffer = file.get_buffer(file.get_length())
		var stream = AudioStreamMP3.new()
		stream.data = buffer
		audio_player.stop()
		audio_player.stream = stream
		audio_player.play()


func unload_level():
	if (is_instance_valid(level_instance)):
		level_instance.queue_free()
	level_instance = null


func load_level(level_name: String, unload_previous: bool):
	animation_player.play("fade")
	await animation_player.animation_finished
	
	if unload_previous:
		unload_level()
	
	root_menu.hide()
	var level_path := "res://scenes/%s.tscn" % level_name
	var level_resource := load(level_path)
	if (level_resource):
		level_instance = level_resource.instantiate()
		Global.current_level = level_name
		if (level_name == "level_1"):
			main_2d.add_child(level_instance)
		else:
			main_2d.call_deferred("add_child", level_instance)
			
	animation_player.play_backwards("fade")


func _on_play_button_pressed():
	for node in main_2d.get_children():
		if node != main_2d.get_node("Camera2D"):
			main_2d.remove_child(node)
	load_level("level_1", true)
	await animation_player.animation_finished
	main_2d.add_child(Global.player)
	play_audio("res://music/Background2.mp3")


func _on_options_button_pressed():
	main_menu.hide()
	options_menu.show()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_back_button_pressed():
	if get_tree().paused == true:
		options_menu.hide()
		pause_menu.show()
	else:
		options_menu.hide()
		main_menu.show()


func _on_pause_options_button_pressed():
	pause_menu.hide()
	options_menu.show()


func _on_pause_back_button_pressed():
	pause_menu.hide()
	main_menu.show()
	root_menu.hide()
	get_tree().paused = false


func _on_pause_menu_button_pressed():
	pause_menu.hide()
	for node in main_2d.get_children():
		if node != main_2d.get_node("Camera2D"):
			main_2d.remove_child(node)
	level_instance = null
	Global.current_enemy = null
	Global.current_level = ""
	Global.battle_in_progress = false
	Global.player_last_coords = Vector2(0, 0)
	Global.player.position = Global.player_spawn_coords
	Global.player.scale = Vector2(1, 1)
	Global.player.can_move = true
	camera.zoom = Vector2(3, 3)
	Global.player_can_dance = false
	Global.enemy_can_dance = false
	get_tree().paused = false
	play_audio("res://music/Background1.mp3")
	hud.hide()
	main_menu.show()


func _on_h_slider_value_changed(value):
	if get_tree().paused:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume_slider.value - 24.0)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
