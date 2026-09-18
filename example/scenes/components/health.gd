class_name Health
extends Node

signal damaged(amount: int)
signal died

var hp: int = 0
var _dead: bool = false


func setup(starting_hp: int) -> void:
	hp = starting_hp
	_dead = false


func take_damage(amount: int) -> void:
	if _dead or amount <= 0:
		return
	hp = maxi(0, hp - amount)
	damaged.emit(amount)
	if hp <= 0:
		_dead = true
		died.emit()
