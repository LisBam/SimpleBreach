extends WeaponBase

@onready var bullet_spawn_points: Array[Node2D] = [
	$BulletSpawnPosition,
	$BulletSpawnPosition2,
	$BulletSpawnPosition3
]

# 重写获取发射信息的函数
func _get_spawn_infos() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	
	for spawn_point in bullet_spawn_points:
		# 计算方向
		var fire_dir = (spawn_point.global_position - global_position).normalized()
		
		# 添加到列表
		list.append({
			"pos": spawn_point.global_position,
			"dir": fire_dir
		})
		
	return list
