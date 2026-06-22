extends Node

func _ready():
	ItemPool.load_item_scenes()
	MusicManager.play_background()

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		# TODO: Implement Pause Screen
		# Now it only goes back to the main menu
		get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
