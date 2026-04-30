extends Control

@onready var main_buttons: VBoxContainer = $main_buttons
@onready var settings: Panel = $settings
@onready var logo: Panel = $logo

func _ready():
	main_buttons.visible = true
	settings.visible = false
	
func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/game.tscn")
	
func _on_settings_pressed() -> void:
	main_buttons.visible = false
	settings.visible = true
	logo.visible = false
	
func _on_exit_game_pressed() -> void:
	get_tree().quit()

func _on_back_to_main_pressed() -> void:
	main_buttons.visible = true
	settings.visible = false
	logo.visible = true
