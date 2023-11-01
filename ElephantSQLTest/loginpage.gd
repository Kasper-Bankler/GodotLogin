extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var main_scene=preload("res://main_scene.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	get_tree().change_scene_to(main_scene)
