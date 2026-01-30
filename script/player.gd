class_name Player
extends CharacterBody2D

@onready var far_weapon_parent = $Weapon/FarWeapon

@onready var move_component = $Component/MoveComponent
@onready var face_to_mouse_component = $Component/FaceToMouseComponent
@onready var change_weapon_component = $Component/ChangeWeaponComponent
@onready var hp_component = $Component/HpComponent
@onready var camera = $Camera

var current_far_weapon: WeaponBase

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	change_weapon_component.next_or_last_weapon.connect(next_or_last_weapon)
	#test
	if Input.is_action_just_pressed("mouse_right"):
		spawn_enemy()
	#test

func AttackComponent_far_attack():
	if not current_far_weapon:
		print("未装备远程武器！发射失败！")
		return
	current_far_weapon.shoot()
	
func AttackComponent_near_attack():
	pass
	#print("player检测到发起近战攻击")

func equip_weapon(uid:String): #装备武器
	# 强制重置移动组件状态（防止旧武器还在CD中导致永远无法移动）
	if move_component:
		move_component.set_move_lock(false)
	# 清除旧武器
	for old_weapon in far_weapon_parent.get_children():
		old_weapon.queue_free()
	var weapon_scene = load(uid)
	var weapon = weapon_scene.instantiate()
	current_far_weapon = weapon
	var target_parent = $Weapon/FarWeapon
	if target_parent:
		target_parent.add_child(weapon)
		apply_weapon_stats(weapon)
	else:
		printerr("挂载武器时出错！")

# --- 核心逻辑：应用武器属性 ---
func apply_weapon_stats(weapon: WeaponBase):
	print("正在应用武器属性：", weapon.name)
	# 1. 连接转向速度
	# 将武器定义的 rotate_speed 赋值给 转向组件的 rotate_speed
	if face_to_mouse_component:
		face_to_mouse_component.rotate_speed = weapon.rotate_speed
		
	# 2. 传递武器的移动速度倍率
	move_component.weapon_speed_change_mul = weapon.speed_change_mul

	# 3. 连接后坐力信号 (如果尚未连接)
	# 3. 核心连接：武器信号 -> 移动组件方法
	# 注意：我们需要处理一下信号参数，因为信号发的是 (dir, force)
	# 而 move_component 需要的是 (Vector2)
	weapon.request_recoil.connect(_on_weapon_recoil_received)
	
	# --- 连接移动锁定信号 ---
	# 只有当武器确实开启了“射击停止移动”功能时才连接
	if weapon.attacking_stop_move:
		if not weapon.lock_movement_state.is_connected(move_component.set_move_lock):
			weapon.lock_movement_state.connect(move_component.set_move_lock)

	#连接摄像机晃动信号
	weapon.shake_camera.connect(shake_camera)

# 信号中转站：把(方向, 力度)转换为一个向量传给组件
func _on_weapon_recoil_received(dir: Vector2, force: float):
	var impulse = -dir * force
	move_component.apply_impulse(impulse)

func next_or_last_weapon(next_or_last:int):
	if next_or_last == 1:
		#printerr("下一把武器")
		equip_weapon("uid://2jixmbigbr6g")
	if next_or_last == -1:
		#printerr("上一把武器")
		equip_weapon("uid://garliwv8t6jf")
		
func hurt(damage:int):
	hp_component.hurt(damage)
	shake_camera(damage)
	$Audio/hurt.play()
	
func recover(count:int):
	hp_component.recover(count)

func spawn_enemy():
	var enemy_scene = preload("uid://h3qegnoxe7ho")
	var enemy = enemy_scene.instantiate()
	enemy.global_position = get_global_mouse_position()
	get_tree().root.add_child(enemy)
	
func knock_back(dir: Vector2, force: float):
	var impulse = dir * force
	move_component.apply_impulse(impulse)

func shake_camera(force:float):
	camera.start_shake(force)
