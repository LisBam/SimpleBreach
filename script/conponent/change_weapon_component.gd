extends Node2D

@export var host: CharacterBody2D

signal next_or_last_weapon(next_or_last: int) ##next是1，last是-1/

func _physics_process(delta: float) -> void:
	if not host: 
		printerr("切枪组件未绑定宿主！")
		return
		
	if Input.is_action_just_pressed("mouse_wheel_down"):
		next_or_last_weapon.emit(1)
	if Input.is_action_just_pressed("mouse_wheel_up"):
		next_or_last_weapon.emit(-1)
