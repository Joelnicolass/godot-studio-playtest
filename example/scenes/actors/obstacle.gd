@tool
class_name Obstacle
extends Area3D

@export var data: ObstacleData:
	set(value):
		data = value
		if is_node_ready():
			_apply_data()

@export var cube_color: Color = Color(0.86, 0.32, 0.28):
	set(value):
		cube_color = value
		if is_node_ready():
			_apply_color()


func _ready() -> void:
	_apply_data()
	_apply_color()
	if Engine.is_editor_hint():
		return
	if get_tree().current_scene == self:
		var cam := get_node_or_null("F6Camera") as Camera3D
		if cam:
			cam.current = true


func _apply_data() -> void:
	if data == null:
		return
	var mesh_instance := get_node_or_null("%Mesh") as MeshInstance3D
	if mesh_instance:
		var box := BoxMesh.new()
		box.size = data.size
		mesh_instance.mesh = box
	var collision := get_node_or_null("%Shape") as CollisionShape3D
	if collision:
		var shape := BoxShape3D.new()
		shape.size = data.size
		collision.shape = shape


func _apply_color() -> void:
	var mesh_instance := get_node_or_null("%Mesh") as MeshInstance3D
	if mesh_instance == null:
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_color = cube_color
	mesh_instance.material_override = mat


func _get_configuration_warnings() -> PackedStringArray:
	if data == null:
		return PackedStringArray(["Assign ObstacleData."])
	return PackedStringArray()
