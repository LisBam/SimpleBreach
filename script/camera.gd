extends Camera2D # 如果是 3D 场景，请改为 Camera3D

@export var noise : FastNoiseLite = FastNoiseLite.new()
@export var shake_speed : float = 30.0  # 晃动的频率
@export var decay_rate : float = 10.0     # 强度衰减速度


var shake_strength : float = 0.0 # 当前剩余强度
var noise_i : float = 0.0        # 用于在噪声图上移动的索引

func _ready():
	# 初始化噪声参数，让晃动更柔和
	noise.seed = randi()
	noise.frequency = 0.5
	

func _process(delta):
	# 随时间衰减晃动强度
	shake_strength = lerp(shake_strength, 0.0, decay_rate * delta)
	
	if shake_strength > 0.1:
		apply_shake(delta)
	else:
		offset = Vector2.ZERO # 停止后归位（3D则修改 position/rotation）

# 外部调用此方法传入强度
func start_shake(intensity: float):
	shake_strength = intensity

func apply_shake(delta):
	noise_i += delta * shake_speed
	# 使用噪声计算偏移量，结果在 -1 到 1 之间，再乘以当前强度
	var shake_offset = Vector2(
		noise.get_noise_2d(noise_i, 0),
		noise.get_noise_2d(0, noise_i)
	) * shake_strength
	
	offset = shake_offset
