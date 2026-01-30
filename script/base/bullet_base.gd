class_name BulletBase
extends Area2D

@onready var sprite:Sprite2D = $Sprite2D
@onready var collision_shape:CollisionShape2D = $CollisionShape2D

#在武器中被赋值
var speed:float
var damage:int
var penetrate_count:int ##子弹穿透数量
var bullet_distance:float ##子弹射程
var knockback_force:float ##击退强度

var direction: Vector2 = Vector2.ZERO # 子弹飞行方向向量
var start_pos: Vector2 # 记录子弹的初始发射位置，用于判断超出射程
var has_hurt_target:int = 0

func _ready() -> void:
	start_pos = global_position

# 参数为Vector2方向向量，直接接收武器传来的方向
func set_direction(dir: Vector2) -> void:
	# 判空：避免传入空向量导致方向异常
	if dir == Vector2.ZERO:
		return
	# 赋值飞行方向（直接用武器传来的归一化方向向量）
	direction = dir
	# 子弹自身旋转，和飞行方向一致（360°朝向匹配，视觉无偏差）
	global_rotation = dir.angle()

# 物理帧更新：子弹飞行（原有逻辑完全不变，无需修改）
func _physics_process(delta: float) -> void:
	# 360°飞行：方向向量 * 速度 * delta（帧率无关）
	if direction != Vector2.ZERO:
		global_position += direction * speed * delta
		
	distance_to_queue()
		
func distance_to_queue(): #超出射程销毁
	# 核心新增：计算当前位置到初始位置的距离，超过射程则销毁
	if global_position.distance_to(start_pos) >= bullet_distance:
		queue_free() # 销毁自身，释放资源

func _on_body_entered(body: Node2D) -> void:
	if has_hurt_target>penetrate_count:
		return
	if body.is_in_group("enemy"):
		body.hurt(damage)
		to_knock_back(body)
		has_hurt_target+=1
	if has_hurt_target>penetrate_count:
		queue_free()
		
func to_knock_back(target):
	#击退
	var dir = (target.global_position - global_position).normalized()
	target.knock_back(dir, knockback_force)
