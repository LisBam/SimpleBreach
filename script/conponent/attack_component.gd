extends Node2D
@export var host: CharacterBody2D

func _physics_process(delta: float) -> void:
	if not host: 
		printerr("攻击组件未绑定宿主！")
		return
		
	if Input.is_action_pressed("mouse_left"):
		#print("攻击组件检测到发起远程攻击！")
		host.AttackComponent_far_attack()
		
	if Input.is_action_pressed("mouse_right"):
		#print("攻击组件检测到发起近战攻击！")
		host.AttackComponent_near_attack()
		
