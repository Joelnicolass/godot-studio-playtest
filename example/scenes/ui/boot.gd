class_name Boot
extends Control

@onready var _play: Button = %PlaySolo
@onready var _status: Label = %Status
@onready var _after: Label = %AfterPlay


func _ready() -> void:
	_play.pressed.connect(_on_play)


func _on_play() -> void:
	_play.disabled = true
	_status.text = "Jugando"
	_after.visible = true
	get_tree().change_scene_to_file("res://scenes/world/run.tscn")
