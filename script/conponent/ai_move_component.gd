extends MoveComponent

#重写方向控制移动
func control_move():
	var move_dir = Vector2.ZERO
	#额外判断如果未锁定目标，则原地待机
	if host.lock_target_component.lock_target:
		if not is_locked:
			move_dir=(face_marker.global_position - host.global_position).normalized()
	var target_velocity = move_dir * move_speed
	if move_dir.length() > 0:
		# 有输入时，向目标速度加速
		host.velocity = host.velocity.lerp(target_velocity, acceleration)
	else:
		# 无输入时，施加摩擦力减速
		host.velocity = host.velocity.lerp(Vector2.ZERO, friction)
	host.move_and_slide()
