@tool
class_name ShipSteer
extends Node

@export var actor: Ship
@export var rules: MatchRules


func _ready() -> void:
	if actor == null:
		actor = get_parent() as Ship
	if rules == null and actor != null:
		rules = actor.rules
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or actor == null:
		return
	var direction := Input.get_vector("move_left", "move_right", "move_down", "move_up")
	actor.apply_steer(direction, delta)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if actor == null:
		warnings.append("Assign a Ship actor.")
	if rules == null:
		warnings.append("Assign MatchRules.")
	return warnings
