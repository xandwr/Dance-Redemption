extends StaticBody2D

@export var enabled = true

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var point_light_2d = $PointLight2D

func _ready():
	animation_tree.set("parameters/State/blend_position", 1)
	state_machine.travel("State")

func _process(_delta):
	if (enabled):
		animation_tree.set("parameters/State/blend_position", 1)
		point_light_2d.enabled = true;
	else:
		animation_tree.set("parameters/State/blend_position", -1)
		point_light_2d.enabled = false;

func interact():
	enabled = !enabled
