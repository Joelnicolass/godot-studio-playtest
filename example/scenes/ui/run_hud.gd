class_name RunHud
extends CanvasLayer

@onready var crash_banner: Label = $CrashBanner
@onready var hp_label: Label = $HpLabel
@onready var hit_label: Label = %HitLabel


func _ready() -> void:
	crash_banner.visible = false
	hit_label.visible = false


func set_hp(hp: int) -> void:
	hp_label.text = "HP %d" % hp


func show_crash() -> void:
	crash_banner.visible = true


func show_hit() -> void:
	hit_label.visible = true
