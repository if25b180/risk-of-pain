extends Node2D

func _ready():
	visible = false

func pretty_print(name: String) -> String:
	var words = name.split("_")
	for i in range(words.size()):
		words[i] = words[i].capitalize()
	return " ".join(words)

func activate():
	visible = true
	var text = ""
	if not Util.get_player():
		return
	
	Util.get_player().stats.health = Util.get_player().stats.max_health
	
	var dict = Util.get_player().stats
	for key in dict:
		match key:
			"max_health", \
			"slipperiness", \
			"jump_force", \
			"jump_release_multiplier", \
			"wall_jump_force", \
			"pogo_force", \
			"damage_secondary", \
			"gravity", \
			"parry_force":
				continue
		
		text += "  - " + pretty_print(str(key)) + ": " + str(dict[key]) + "\n"
	
	var ps = Util.get_player().stats
	var total_score = ps.max_health * ps.damage_primary * ps.speed * ps.kills * ps.total_items_collected
	var total_score_str = "\nTotal Score: " + str(total_score)
	
	$WinScreen.text = "You won! Final Stats: \n" + text + total_score_str
