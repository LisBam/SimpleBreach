extends Node2D

@onready var attack_timer: Timer = $AttackArea/AttackCdTimer
@onready var attack_area: Area2D = $AttackArea

@export var knockback_force:float = 2000
@export var damage:int = 10
@export var attack_cd: float = 1.0:
	set(v):
		attack_cd = v
		if is_node_ready():
			attack_timer.wait_time = attack_cd

# 用于存储当前在攻击范围内的目标
var _targets_in_range: Array[Node2D] = []

# 字典格式： { 目标节点: 上次受击时的系统时间(毫秒) }
var _last_hit_times: Dictionary = {}

func _ready() -> void:
	# 初始化 Timer
	attack_timer.wait_time = attack_cd

func _on_attack_cd_timer_timeout() -> void:
	_apply_damage_to_all()
	
func _apply_damage_to_all() -> void:
	var current_time = Time.get_ticks_msec()
	
	# 倒序遍历（从大索引到小索引），这样删除元素不会导致数组索引错乱
	for i in range(_targets_in_range.size() - 1, -1, -1):
		var target = _targets_in_range[i]
		
		# 1. 检查对象是否还在内存中
		if not is_instance_valid(target):
			_targets_in_range.remove_at(i)
			continue
			
		# 2. 检查逻辑上的死亡（比如血量归零但还没来得及 queue_free）
		# 假设你的目标血量组件里有一个 is_dead 变量
		#if target.has_method("is_dead") and target.is_dead():
			#_targets_in_range.remove_at(i)
			#continue
			
		# --- 核心修改：检查独立冷却 ---
		var last_time = _last_hit_times.get(target, 0)
		# 如果距离上次受伤还不到 CD 时间，跳过这次伤害
		if current_time - last_time < attack_cd * 1000:
			continue
		# ---------------------------
		
		# 3. 确实活着，施加伤害
		if target.has_method("hurt"):
			target.hurt(damage)
			# 更新该目标的受伤时间
			_last_hit_times[target] = current_time
		
		#施加击退
		var dir = (target.global_position - global_position).normalized()
		target.knock_back(dir,knockback_force)
	
	# 如果清理完发现没人了，关掉计时器
	if _targets_in_range.is_empty():
		attack_timer.stop()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("hurt"):
		if not _targets_in_range.has(body):
			_targets_in_range.append(body)
# --- 核心修改：进入时不无脑伤害，先查表 ---
		var current_time = Time.get_ticks_msec()
		var last_time = _last_hit_times.get(body, -999999) # 默认给个很小的值确保第一次能打。
			
		# 只有当 CD 冷却完毕，才立即触发“见面礼”伤害
		if current_time - last_time >= attack_cd * 1000:
			# 这里只对当前进入的这一个 body 造成伤害，不要调用 apply_to_all 避免重复
			_apply_damage_to_target(body) 
		
		# 无论是否造成了伤害，都要确保 Timer 跑起来处理后续
		if attack_timer.is_stopped():
			attack_timer.start()

func _on_attack_area_body_exited(body: Node2D) -> void:
	if _targets_in_range.has(body):
		_targets_in_range.erase(body)
	
	# 注意：离开时不要删除 _last_hit_times 里的记录！
	# 必须保留记录，防止它马上走回来刷 CD。
	
	# 如果范围内没人了，停止计时
	if _targets_in_range.is_empty():
		attack_timer.stop()

# 抽取单体伤害逻辑
func _apply_damage_to_target(target: Node2D):
	if target.has_method("hurt"):
		target.hurt(damage)
		_last_hit_times[target] = Time.get_ticks_msec()
	var dir = (target.global_position - global_position).normalized()
	target.knock_back(dir, knockback_force)
