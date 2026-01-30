extends ColorRect

func _ready():
	visible = true
	# 初始状态：完全不透明（可省略，默认就是1.0）
	self.modulate.a = 1.0
	# 创建补间动画，实现平滑淡出
	var tween = create_tween()
	# 核心：tween_property(目标节点, 要修改的属性, 目标值, 过渡时长)
	# modulate:a = 0.0 是完全透明，2.0 表示淡出耗时2秒（可自行修改）
	tween.tween_property(self, "modulate:a", 0.0, 2.5)
