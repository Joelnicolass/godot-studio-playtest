class_name Run
extends Node3D

@export var rules: MatchRules
@onready var ship: Ship = %Ship
@onready var hud: RunHud = $RunHud


func _ready() -> void:
	if ship and ship.health:
		hud.set_hp(ship.health.hp)
		ship.health.damaged.connect(_on_ship_damaged)
		ship.crashed.connect(_on_ship_crashed)
	if ship and ship.ship_gun:
		ship.ship_gun.obstacle_hit.connect(_on_obstacle_hit)


func _on_ship_damaged(_amount: int) -> void:
	if ship and ship.health:
		hud.set_hp(ship.health.hp)


func _on_ship_crashed() -> void:
	hud.show_crash()


func _on_obstacle_hit() -> void:
	hud.show_hit()
