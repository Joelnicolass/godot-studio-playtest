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
