extends Label
## 	For new enemies:
#	add for e.g. const floating_text = preload("res://scenes/particles/floating_text.tscn") to the script
#	use int(number) wenn calling function with a number

func setup(input_text, color: Color = Color.RED):
	text = str(input_text)
	modulate = color
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 50, 0.8)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.8)
	tween.tween_callback(queue_free)
