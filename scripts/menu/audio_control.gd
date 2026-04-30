extends CheckButton

func _ready() -> void:
	button_pressed = not AudioServer.is_bus_mute(0)
	toggled.connect(_on_toggled)

func _on_toggled(pressed: bool) -> void:
	AudioServer.set_bus_mute(0, not pressed)
