extends Sprite2D

var shit_damage = 15
var shit_speed = 2

func _physics_process(_delta: float) -> void:
	global_position.y += shit_speed


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is TileMap or body is TileMapLayer:
		queue_free()
		return
		
	if body is Player:
		body.hurt(shit_damage)
		queue_free()
