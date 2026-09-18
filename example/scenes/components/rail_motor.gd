@tool
class_name RailMotor
extends Node

@export var actor: CharacterBody3D
@export var rules: MatchRules
@export var enabled: bool = true


func _ready() -> void:
	if actor == null:
		actor = get_parent() as CharacterBody3D
	if rules == null and actor != null:
		rules = actor.get("rules") as MatchRules
	set_physics_process(true)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or not enabled or actor == null or rules == null:
		return
	actor.velocity.z = -rules.rail_speed
	actor.move_and_slide()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if actor == null:
		warnings.append("Assign a CharacterBody3D actor.")
	if rules == null:
		warnings.append("Assign MatchRules.")
	return warnings
