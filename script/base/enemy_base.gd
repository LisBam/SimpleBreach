extends CharacterBody2D

@onready var hp_component = $Component/HpComponent
@onready var lock_target_component = $Component/LockTargetComponent
@onready var face_marker = $face_marker
@onready var ai_move_component = $Component/AIMoveComponent


func _physics_process(delta: float) -> void:
	has_target()

func hurt(damage:int):
	hp_component.hurt(damage)
	$Audio/hurt.play()
	
func recover(count:int):
	hp_component.recover(count)

func has_target():
	if hp_component.hp<=0:
		return
	var target = lock_target_component.lock_target
	if target != null:
		face_marker.visible = true
		face_to_target(target)
	else:
		face_marker.visible = false

func face_to_target(target): #面向目标
	if target:
		# 平滑转向目标
		var target_dir = (target.global_position - global_position).angle()
		rotation = lerp_angle(rotation, target_dir, 0.1)

func knock_back(dir: Vector2, force: float):
	var impulse = dir * force
	ai_move_component.apply_impulse(impulse)
