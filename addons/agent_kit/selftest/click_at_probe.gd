extends Node

## Probe of the click_at self-test. Records the mouse events that reach it, the way a board
## (a GridView3D) takes a click in _unhandled_input and picks the cell with the camera ray.
## Read by `assert {node: "%Probe", prop: ...}` in click_at.json.

@export var camera: Camera3D
@export var cover: Button

## Presses seen by _input (before the GUI): every click, also the ones a Control takes.
var input_presses := 0
## Presses that reached _unhandled_input: the ones no Control took.
var clicks := 0
var releases := 0
var motions := 0
var last_button := 0
## event.position of the last press, in viewport pixels.
var last_x := -1.0
var last_y := -1.0
## Where the camera ray of the last press meets the ground (y = 0).
var hit_x := 0.0
var hit_z := 0.0
## Presses of the Button that covers the top-left corner.
var cover_presses := 0


func _ready() -> void:
	cover.pressed.connect(_on_cover_pressed)


func _input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb != null and mb.pressed:
		input_presses += 1


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		motions += 1
		return
	var mb := event as InputEventMouseButton
	if mb == null:
		return
	if not mb.pressed:
		releases += 1
		return
	clicks += 1
	last_button = mb.button_index
	last_x = mb.position.x
	last_y = mb.position.y
	var origin := camera.project_ray_origin(mb.position)
	var normal := camera.project_ray_normal(mb.position)
	var hit: Variant = Plane(Vector3.UP, 0.0).intersects_ray(origin, normal)
	if hit != null:
		var point: Vector3 = hit
		hit_x = point.x
		hit_z = point.z


func _on_cover_pressed() -> void:
	cover_presses += 1
