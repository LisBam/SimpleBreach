extends Node2D

const PLAYER_SCENE: PackedScene = preload("uid://bcflwsmno1nfw")

func _ready() -> void:
	spawn_player()
	
func spawn_player():
	var player = PLAYER_SCENE.instantiate()
	add_child(player)
	print("player已被载入场景")
