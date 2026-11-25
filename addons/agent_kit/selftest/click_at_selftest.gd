extends Node

## Self-test of the click_at flow step. Headless, no game content, no window:
##   godot --headless --path PROJECT res://addons/agent_kit/selftest/click_at_selftest.tscn
## Runs click_at.json against click_at_world.tscn three times: with the project's own window
## settings, with the root stretched in canvas_items mode, and in viewport mode (a web window that
## changed size), then the error cases. Prints CLICK_AT_SELFTEST PASS, or FAIL with every broken
## case, and quits 0 or 1.

const Flow := preload("res://addons/agent_kit/agent_flow.gd")
const FLOW_PATH := "res://addons/agent_kit/selftest/click_at.json"
const OUT_DIR := "user://agent_kit_selftest"

## Each error case: one step, and a piece of the message the step must fail with.
const ERROR_CASES := [
	[{"click_at": {"x": -5, "y": 10}}, "off screen"],
	[{"click_at": {"x": 100000, "y": 10}}, "off screen"],
	[{"click_at": {"world": [100, 0, 0]}}, "off screen"],
	[{"click_at": {"world": [0, 0, 50]}}, "behind the camera"],
	[{"click_at": {"world": [1, 2]}}, "[x, y, z]"],
	[{"click_at": {"world": "here"}}, "[x, y, z]"],
	[{"click_at": {"x": "a", "y": 1}}, "must be numbers"],
	[{"click_at": {"x": 10}}, "needs {x, y}"],
	[{"click_at": {}}, "needs {x, y}"],
	[{"click_at": {"x": 1, "y": 1, "world": [0, 0, 0]}}, "not both"],
	[{"click_at": {"x": 10, "y": 10, "button": "side"}}, "button must be"],
	[{"click_at": "%Probe"}, "click_at step must be"],
]

var _failures := PackedStringArray()


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var spec: Variant = JSON.parse_string(FileAccess.get_file_as_string(FLOW_PATH))
	if typeof(spec) != TYPE_DICTIONARY:
		_finish(PackedStringArray(["%s is not a JSON object" % FLOW_PATH]))
		return
	var root := get_tree().root
	print("CLICK_AT_SELFTEST window=%s visible=%s" % [root.size, root.get_visible_rect().size])
	await _flow_case("project settings", spec)
	var mode_before := root.content_scale_mode
	var size_before := root.content_scale_size
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_size = Vector2i(800, 450)
	await _flow_case("canvas_items 800x450", spec)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_size = Vector2i(960, 540)
	await _flow_case("viewport 960x540", spec)
	root.content_scale_mode = mode_before
	root.content_scale_size = size_before
	await _error_cases(str(spec["scene"]))
	_finish(_failures)


func _flow_case(label: String, spec: Dictionary) -> void:
	await get_tree().process_frame
	var root := get_tree().root
	var screen := root.get_screen_transform()
	print(
		(
			"CLICK_AT_SELFTEST case=%s visible=%s scale=%s"
			% [label, root.get_visible_rect().size, screen.get_scale()]
		)
	)
	var fixture := await _mount(str(spec["scene"]))
	var body: Dictionary = spec.duplicate(true)
	body.erase("scene")
	var fail: String = await Flow.new().run(get_tree(), body, OUT_DIR)
	if not fail.is_empty():
		_failures.append("%s: %s" % [label, fail])
	fixture.queue_free()
	await get_tree().process_frame


func _error_cases(scene_path: String) -> void:
	var fixture := await _mount(scene_path)
	var probe := fixture.get_node("%Probe")
	for case in ERROR_CASES:
		var step: Dictionary = case[0]
		var want: String = case[1]
		var before := int(probe.get("input_presses"))
		var fail: String = await Flow.new().run(
			get_tree(), {"wait_first": 0.0, "steps": [step]}, OUT_DIR
		)
		if not fail.contains(want):
			_failures.append(
				"error case %s: want '%s', got '%s'" % [JSON.stringify(step), want, fail]
			)
		elif int(probe.get("input_presses")) != before:
			_failures.append("error case %s sent a click anyway" % JSON.stringify(step))
		else:
			print("CLICK_AT_SELFTEST error ok: ", fail)
	var camera: Camera3D = fixture.get_node("%Camera")
	camera.clear_current(false)
	var no_camera: String = await Flow.new().run(
		get_tree(), {"wait_first": 0.0, "steps": [{"click_at": {"world": [0, 0, 0]}}]}, OUT_DIR
	)
	if not no_camera.contains("Camera3D"):
		_failures.append("no camera: want a Camera3D error, got '%s'" % no_camera)
	else:
		print("CLICK_AT_SELFTEST error ok: ", no_camera)
	var pixels: String = await Flow.new().run(
		get_tree(), {"wait_first": 0.0, "steps": [{"click_at": {"x": 300, "y": 200}}]}, OUT_DIR
	)
	if not pixels.is_empty():
		_failures.append("x/y without a camera: %s" % pixels)
	fixture.queue_free()
	await get_tree().process_frame


## The fixture becomes the current scene, so the flow resolves %Probe in it; this node stays.
func _mount(scene_path: String) -> Node:
	var fixture := (load(scene_path) as PackedScene).instantiate()
	get_tree().root.add_child(fixture)
	get_tree().current_scene = fixture
	await get_tree().process_frame
	return fixture


func _finish(failures: PackedStringArray) -> void:
	if failures.is_empty():
		print("CLICK_AT_SELFTEST PASS")
		get_tree().quit(0)
		return
	for line in failures:
		print("CLICK_AT_SELFTEST FAIL ", line)
	print("CLICK_AT_SELFTEST FAIL")
	get_tree().quit(1)
