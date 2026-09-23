class_name Projectile
extends Area3D

signal hit

@export var speed: float = 48.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	global_position += Vector3(0.0, 0.0, -speed) * delta


func _on_area_entered(area: Area3D) -> void:
	var obstacle := area as Obstacle
	if obstacle == null:
		return
	hit.emit()
	obstacle.queue_free()
	queue_free()
