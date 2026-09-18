class_name Hurtbox3D
extends Area3D

signal hit_body(body: Node3D)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _on_body_entered(body: Node3D) -> void:
	hit_body.emit(body)


func _on_area_entered(area: Area3D) -> void:
	hit_body.emit(area)
