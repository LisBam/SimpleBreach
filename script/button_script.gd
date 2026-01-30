extends Button

func _on_mouse_entered() -> void:
	add_theme_color_override("font_color","#acacac")

func _on_mouse_exited() -> void:
	add_theme_color_override("font_color","#ffffff")

func _on_button_down() -> void:
	add_theme_color_override("font_color","#acacac")

func _on_button_up() -> void:
	add_theme_color_override("font_color","#ffffff")

func _on_pressed() -> void:
	print("begin game button be pressed")
	get_tree().change_scene_to_file("uid://cvc0xat168obp")
