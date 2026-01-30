class_name WeaponBase
extends Node2D

@onready var attack_cd_timer = $AttackCDTimer
@onready var bullet_spawn_position = $BulletSpawnPosition

@export_group("武器属性")
@export var attack_cd:float = 0.5 ##攻击间隔
@export var recoil:float = 500 ##后坐力
@export var attacking_stop_move: bool = true ## 是否在前后摇期间禁止移动
@export var startup_time: float = 0.1  ## 前摇时间
@export var recovery_time: float = 0.2 ## 后摇时间
@export var rotate_speed:float = 10 ##持有武器时的转向速度
@export var speed_change_mul:float = 1 ##持有武器时的速度改变倍率
@export var shake_camera_force:float = 2 ##射击时摄像机晃动幅度

@export_group("子弹相关") 
#@export var bullet:Array[BulletBase] = [] ##所发射的子弹
@export var bullet_scene:PackedScene = preload("uid://dc271xkh6dwem")
@export var speed:float = 2000
@export var damage:int = 20
@export var penetrate_count:int = 0 ##子弹穿透数量
@export var bullet_distance:float = 1000 ##子弹射程
@export var knockback_force:float = 500 ##击退强度
@export var bullet_scale_mul:float = 1.0 ##子弹的贴图和碰撞箱大小倍率

var can_shoot:bool = true
# 定义信号：请求后坐力 (方向，力度)
signal request_recoil(direction: Vector2, force: float)
# 通知是否需要锁定移动
signal lock_movement_state(is_locked: bool)
# 传递摄像机晃动
signal shake_camera(force: float)

func _ready() -> void:
	attack_cd_timer.wait_time = attack_cd

#func reset_bullet_params(bullet):
	#bullet.speed = speed
	#bullet.damage = damage
	#bullet.penetrate_count = penetrate_count
	#bullet.bullet_distance = bullet_distance

#func shoot():
	#if can_shoot:
		#can_shoot = false
		#attack_cd_timer.start()
		#
		#var bullet = bullet_scene.instantiate()
		#var bullet_direction: Vector2 = ($BulletSpawnPosition.global_position - $".".global_position).normalized()
		#reset_bullet_params(bullet)
		#bullet.set_direction(bullet_direction)
		#bullet.global_position = bullet_spawn_position.global_position
		#get_tree().root.add_child(bullet)
		#
func shoot():
	if not can_shoot:
		return
	
	# 1. 流程控制：CD 和 状态
	can_shoot = false
	attack_cd_timer.start()
	
	# 2. 【前摇阶段】
	# 如果设置了射击不可移动，立即锁定
	if attacking_stop_move:
		lock_movement_state.emit(true)
		
	if startup_time > 0:
		# 等待前摇时间
		await get_tree().create_timer(startup_time).timeout
		
		# 安全检查：如果在等待期间武器被销毁或切换了，停止执行
		if not is_instance_valid(self) or not is_inside_tree():
			return

	_execute_attack_logic()#执行攻击逻辑
	#摄像机晃动
	shake_camera.emit(shake_camera_force)
	#枪声
	$Audio/shoot.play()

	# 4. 【后摇阶段】
	if recovery_time > 0:
		await get_tree().create_timer(recovery_time).timeout
	
	# 5. 【动作结束】解除移动锁定
	# 注意：此时 CD 可能还没转好，但玩家已经可以动了
	if attacking_stop_move:
		lock_movement_state.emit(false)
		
func _execute_attack_logic(): #执行攻击逻辑，作用其实是保持代码整洁，独立出来
	# --- 计算并发送后坐力信号 ---
	# 假设武器是朝向鼠标旋转的，Vector2.RIGHT.rotated(global_rotation) 就是枪口朝向
	# 如果你的武器不旋转，而是根据鼠标位置计算，则使用 (鼠标 - 玩家).normalized()
	var shoot_dir = (bullet_spawn_position.global_position - global_position).normalized()
	# 发出信号：方向是射击方向，力度是 recoil 属性
	request_recoil.emit(shoot_dir, recoil)
	# -------------------------------
	
	# 2. 获取所有发射信息（这是子类需要重写的部分，如果需要的话）
	# 返回一个结构数组: [{pos: Vector2, dir: Vector2}]
	var spawn_infos = _get_spawn_infos()
	
	# 3. 统一生成逻辑
	for info in spawn_infos:
		_create_one_bullet(info.pos, info.dir)
	


# --- 虚函数/钩子函数 (供子类修改) ---
# 默认实现：只从 $BulletSpawnPosition 发射一个
func _get_spawn_infos() -> Array[Dictionary]:
	var default_dir = (bullet_spawn_position.global_position - global_position).normalized()
	return [{
		"pos": bullet_spawn_position.global_position,
		"dir": default_dir
	}]

# --- 统一的生成逻辑 (通常不需要子类重写) ---

func _create_one_bullet(spawn_pos: Vector2, direction: Vector2):
	var bullet = bullet_scene.instantiate()
	
	# 设置物理属性
	bullet.global_position = spawn_pos
	bullet.set_direction(direction)
	
	get_tree().root.add_child(bullet)
	
	# 应用数值属性
	_reset_bullet_params(bullet)

func _reset_bullet_params(bullet):
	# 在这里统一赋值，以后加吸血、暴击只要改这里一个地方
	bullet.speed = speed
	bullet.damage = damage
	bullet.penetrate_count = penetrate_count
	bullet.bullet_distance = bullet_distance
	bullet.knockback_force = knockback_force
	bullet.sprite.scale *= Vector2(bullet_scale_mul,bullet_scale_mul)
	bullet.collision_shape.scale *= Vector2(bullet_scale_mul,bullet_scale_mul)
	
func _on_attack_cd_timer_timeout() -> void:
	can_shoot = true
