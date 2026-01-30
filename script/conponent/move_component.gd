class_name MoveComponent
extends Node

@export var face_marker :Sprite2D

# 2D移动组件：即插即用，挂在角色子节点即可实现WASD移动
# 组件化设计，和宿主角色解耦

# 绑定宿主：CharacterBody2D节点（在编辑器面板拖拽绑定，无需代码）
@export var host: CharacterBody2D

@export var move_speed: float = 300.0
@export var friction: float = 0.15 ## 摩擦力 (0.0 - 1.0)
@export var acceleration: float = 0.2 ## 加速度 (0.0 - 1.0)

var weapon_speed_change_mul:float = 1
var is_locked:bool = false

# 接收输入方向，控制宿主移动
func _physics_process(delta: float) -> void:
	if not host: 
		printerr("移动组件未绑定宿主！")
		return
	control_move()

# 提供一个公共方法，允许外部向宿主施加瞬时力
func apply_impulse(force_vector: Vector2):
	if host:
		host.velocity += force_vector
		
# --- 新增：供外部调用的开关方法 ---
func set_move_lock(locked: bool):
	is_locked = locked
	# 如果你希望射击时瞬间停下而不是滑动停止，可以在这里加一句：
	# if locked: host.velocity = Vector2.ZERO

func control_move():
	var input_dir = Vector2.ZERO
	if not is_locked:
		input_dir = Input.get_vector("left", "right", "up", "down")
	var target_velocity = input_dir * move_speed * weapon_speed_change_mul
	# 施加移动 (关键点：使用 lerp 实现惯性，这样后坐力才不会被瞬间抵消)
	if input_dir.length() > 0:
		# 有输入时，向目标速度加速
		host.velocity = host.velocity.lerp(target_velocity, acceleration)
	else:
		# 无输入时，施加摩擦力减速
		host.velocity = host.velocity.lerp(Vector2.ZERO, friction)
	host.move_and_slide()
