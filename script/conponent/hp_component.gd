extends Node2D

@export var host: CharacterBody2D

@export var max_hp:int = 100
@export var hp:int = 100

func _ready() -> void:
	if not host: 
		printerr("血量组件未绑定宿主！")
		return
	hp = max_hp

func hurt(damage:int):
	hp -= damage
	_be_red()
	#printerr("hp：",hp)
	if hp <= 0:
		#printerr("die!!!!!")
		die()

func recover(count:int):
	hp += count
	hp = min(hp, max_hp)
	#printerr("hp：",hp)
	
func _be_red():
	# 假设你的宿主有一个 Sprite2D 节点，我们直接操作它的颜色
	var sprite = host.get_node("Sprite") # 请根据你实际的节点路径修改
	if not sprite: return

	var tween = create_tween()
	# 1. 瞬间变为红色（或者浅红色）
	sprite.modulate = Color(0.393, 0.0, 0.004, 1.0) # 增加 R 值，大于 1 会产生发光感（如果有环境光）
	# 2. 在 0.1 秒内平滑恢复到正常颜色 (Color.WHITE)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func die():
	if host.is_in_group("enemy"):
		enemy_die()

func enemy_die():
	var sprite = host.get_node("Sprite")
	host.get_node("face_marker").visible = false
	host.get_node("CollisionShape2D").queue_free()
	# 核心：死亡透明淡出动画
	var die_tween = create_tween()
	# 0.5秒内，透明度从1平滑降到0
	die_tween.tween_property(sprite, "modulate:a", 0.0, 0.2)
	# 动画完成后，再销毁宿主节点
	die_tween.finished.connect(func():
		if is_instance_valid(host):
			host.queue_free()
			printerr(host.name, "已销毁")
	)
