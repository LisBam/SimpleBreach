extends Sprite2D

# 可在编辑器实时调整的参数（导出变量）
@export var flash_speed: float = 1.5  ## 闪烁速度，值越大闪得越快
@export var min_alpha: float = 0.2    ## 最小透明度（0=全透，建议0~0.5）
@export var max_alpha: float = 1.0    ## 最大透明度（1=全不透，建议0.5~1）

# 内部变量：透明度变化方向（1=变亮，-1=变暗）
var alpha_dir: int = 1

func _process(delta: float) -> void:
	# 核心：按速度和帧时间更新透明度，保证帧率无关
	modulate.a += alpha_dir * flash_speed * delta
	
	# 到达最小透明度，反转方向（开始变亮）
	if modulate.a <= min_alpha:
		modulate.a = min_alpha  # 限制最小值，避免超界
		alpha_dir = 1
	# 到达最大透明度，反转方向（开始变暗）
	elif modulate.a >= max_alpha:
		modulate.a = max_alpha  # 限制最大值，避免超界
		alpha_dir = -1
