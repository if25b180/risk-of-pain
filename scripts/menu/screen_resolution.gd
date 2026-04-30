extends OptionButton

@onready var screen_resolution: OptionButton = $"."

var resolutions = [
	Vector2i(1280, 720),    # HD
	Vector2i(1366, 768),    # HD (Laptop)
	Vector2i(1600, 900),    # HD+
	Vector2i(1920, 1080),   # Full HD
	Vector2i(2560, 1440),   # WQHD
	Vector2i(3440, 1440),   # UWQHD
	Vector2i(3840, 2160),   # 4K UHD
]

func _ready() -> void:
	var popup := screen_resolution.get_popup()
	popup.add_theme_font_size_override("font_size", 11)
	
	for res in resolutions:
		add_item("%d x %d" % [res.x, res.y])
	
	var current_size = DisplayServer.window_get_size()
	for i in range(resolutions.size()):
		if resolutions[i] == current_size:
			select(i)
			break

	item_selected.connect(_on_resolution_selected)

func _on_resolution_selected(index: int) -> void:
	var new_resolution = resolutions[index]
	DisplayServer.window_set_size(new_resolution)
