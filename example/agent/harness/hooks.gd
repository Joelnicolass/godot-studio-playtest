extends Node

# El `_` en GDScript es convención (style guide / editor help), no un lock de runtime.
# Object.call / callv ejecutan el método si existe — también los `_privados` del producto.


func play_via_private() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return "no_scene"
	if not scene.has_method("_on_play"):
		return "missing__on_play"
	var result: Variant = scene.call("_on_play")
	return "called:%s" % str(result)
