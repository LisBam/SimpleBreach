extends Node2D

@onready var lock_area: Area2D = $LockArea

@export var host: CharacterBody2D
@export var target_group: String = "player"

var lock_target:CharacterBody2D
var _targets_in_range: Array[CharacterBody2D] = []

func _ready() -> void:
	if not host: 
		printerr("索敌组件未绑定宿主！")
		return

func _physics_process(_delta: float) -> void:
	_clean_invalid_targets()
	_update_lock_target()

# 核心逻辑：从数组中筛选最近的目标
func _update_lock_target() -> void:
	if _targets_in_range.is_empty():
		lock_target = null
		return
	
	var nearest_enemy: CharacterBody2D = null
	var min_dist_sq = INF # 使用平方距离效率更高
	
	for target in _targets_in_range:
		var dist_sq = host.global_position.distance_squared_to(target.global_position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			nearest_enemy = target
			
	lock_target = nearest_enemy

func _on_lock_area_body_entered(body: Node2D) -> void:
	if body.is_in_group(target_group) and body is CharacterBody2D:
			if not _targets_in_range.has(body):
				_targets_in_range.append(body)

func _on_lock_area_body_exited(body: Node2D) -> void:
	if _targets_in_range.has(body):
			_targets_in_range.erase(body)

# 关键：清理已死亡（queue_free）的目标，防止空指针报错
func _clean_invalid_targets() -> void:
	for i in range(_targets_in_range.size() - 1, -1, -1):
		if not is_instance_valid(_targets_in_range[i]):
			_targets_in_range.remove_at(i)
