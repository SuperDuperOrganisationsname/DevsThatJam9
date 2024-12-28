extends Control

var pause_menu_active = false

func toggle_pause_menu() -> void:
	print("toggle")
	pause_menu_active = !pause_menu_active
	get_tree().paused = pause_menu_active
	visible = pause_menu_active


func _on_pause_button_button_down() -> void:
	toggle_pause_menu()


func _on_continue_button_button_down() -> void:
	toggle_pause_menu()
