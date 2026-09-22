class_name ShipGun
extends Node3D

signal fired
signal obstacle_hit

@export var projectile_scene: PackedScene
@export var speed: float = 48.0
@export var cooldown: float = 0.35

@onready var muzzle: Marker3D = %Muzzle

var _cooldown_left: float = 0.0


func _ready() -> void:
	set_process(true)


func _process(delta: float) -> void:
	if _cooldown_left > 0.0:
		_cooldown_left = maxf(0.0, _cooldown_left - delta)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("fire"):
		return
	if event.is_echo():
		return
	_try_fire()
	get_viewport().set_input_as_handled()


func _try_fire() -> void:
	if _cooldown_left > 0.0:
		return
	if projectile_scene == null:
		return
	var ship := get_parent() as Node3D
	if ship == null:
		return
	var run_root := ship.get_parent() as Node
	if run_root == null:
		return
	var projectile := projectile_scene.instantiate() as Projectile
	if projectile == null:
		return
	projectile.speed = speed
	projectile.hit.connect(_on_projectile_hit)
	run_root.add_child(projectile)
	projectile.global_position = muzzle.global_position
	projectile.global_basis = Basis.IDENTITY
	_cooldown_left = cooldown
	fired.emit()


func _on_projectile_hit() -> void:
	obstacle_hit.emit()


func _get_configuration_warnings() -> PackedStringArray:
	if projectile_scene == null:
		return PackedStringArray(["Assign a projectile PackedScene."])
	return PackedStringArray()
