@tool
class_name Ship
extends CharacterBody3D

signal crashed

@export var health: Health
@export var hurtbox: Hurtbox3D
@export var rail_motor: RailMotor
@export var ship_steer: ShipSteer
@export var rules: MatchRules
@export var hull_color: Color = Color(0.35, 0.75, 0.95):
	set(value):
		hull_color = value
		if is_node_ready():
			_apply_hull_color()

var _crashed: bool = false


func _ready() -> void:
	_apply_hull_color()
	if Engine.is_editor_hint():
		return
	if health == null:
		health = get_node_or_null("Health") as Health
	if hurtbox == null:
		hurtbox = get_node_or_null("Hurtbox3D") as Hurtbox3D
	if rail_motor == null:
		rail_motor = get_node_or_null("RailMotor") as RailMotor
	if ship_steer == null:
		ship_steer = get_node_or_null("ShipSteer") as ShipSteer
	if health and rules:
		health.setup(rules.starting_hp)
		health.died.connect(_on_died)
	if hurtbox:
		hurtbox.hit_body.connect(_on_hit_body)


func apply_steer(direction: Vector2, _delta: float) -> void:
	if _crashed or rules == null:
		velocity.x = 0.0
		velocity.y = 0.0
		return
	velocity.x = direction.x * rules.steer_speed
	velocity.y = direction.y * rules.steer_speed


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or rules == null:
		return
	position.x = clampf(position.x, rules.strafe_min.x, rules.strafe_max.x)
	position.y = clampf(position.y, rules.strafe_min.y, rules.strafe_max.y)


func _on_hit_body(body: Node3D) -> void:
	if _crashed or health == null:
		return
	var obstacle := body as Obstacle
	if obstacle == null or obstacle.data == null:
		return
	health.take_damage(obstacle.data.damage)


func _on_died() -> void:
	_crashed = true
	velocity = Vector3.ZERO
	if rail_motor:
		rail_motor.enabled = false
	if hurtbox:
		hurtbox.set_deferred("monitoring", false)
	crashed.emit()


func _apply_hull_color() -> void:
	var mesh_instance := get_node_or_null("%Hull") as MeshInstance3D
	if mesh_instance == null:
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_color = hull_color
	mesh_instance.material_override = mat


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if health == null:
		warnings.append("Assign a Health component.")
	if hurtbox == null:
		warnings.append("Assign a Hurtbox3D component.")
	if rail_motor == null:
		warnings.append("Assign a RailMotor component.")
	if ship_steer == null:
		warnings.append("Assign a ShipSteer component.")
	if rules == null:
		warnings.append("Assign MatchRules.")
	return warnings
