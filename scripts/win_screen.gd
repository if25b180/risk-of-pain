extends Node2D

func _ready():
	visible = false

func activate():
	visible = true
	var text = ""
	if not Util.get_player():
		return
	
	var dict = Util.get_player().stats
	for key in dict:
		text += "  - " + str(key) + ": " + str(dict[key]) + "\n"
	$WinScreen.text = "You won! Final Stats: \n" \
		+ text
