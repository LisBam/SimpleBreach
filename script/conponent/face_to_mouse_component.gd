class_name FaceToMouseComponent
extends Node2D
@export var host: CharacterBody2D

@export var rotate_speed:float = 10 ##面向鼠标的转向速度

func _physics_process(delta: float) -> void:
	if not host: 
		printerr("面向目标组件未绑定宿主！")
		return
	keep_face_to_mouse(delta) #保持玩家面向鼠标

func keep_face_to_mouse(DELTA):
	# 获取鼠标的全局坐标
	var mouse_global_pos = get_global_mouse_position()
	# 计算玩家到鼠标的方向向量（归一化，仅保留方向）
	var look_dir = (mouse_global_pos - host.global_position).normalized()
	# 判空：避免玩家和鼠标坐标重合时旋转出错（极少数情况）
	if look_dir == Vector2.ZERO:
		return
	
	# 目标旋转角度：方向向量对应的弧度（和原代码核心一致）
	var target_rotation = look_dir.angle()
	# 自动计算最短旋转角度（关键：返回-π~π之间的差值，自动选近路）
	var rotation_diff = wrapf(target_rotation - host.global_rotation, -PI, PI)
	
	# 控制旋转速度：按帧更新旋转角度（delta是引擎内置帧时间，保证帧率无关）
	# 当旋转差值的绝对值小于步长时，直接贴紧目标角度，避免抖动
	var rotate_step = rotate_speed * DELTA
	if abs(rotation_diff) < rotate_step:
		host.global_rotation = target_rotation
	else:
		# 按最短方向逐步旋转（rotation_diff的正负决定旋转方向）
		host.global_rotation += rotation_diff / abs(rotation_diff) * rotate_step
