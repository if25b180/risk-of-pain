extends Sprite2D

var direction = Vector2.RIGHT
var speed = 5
var life = 3

func _physics_process(delta: float) -> void:
	life -= delta
	if life <= 0:
		queue_free()
		return
	
	global_position += Vector2(direction.x * speed, direction.y * speed)
	rotation = direction.angle()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is TileMap or body is TileMapLayer:
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not area is EnemyHitbox:
		return
		
	var enemy = area.get_parent()
	if not enemy is Enemy:
		print("WARN: EnemyHitbox attached to non-Enemy type")
	
	(enemy as Enemy).hurt(Util.get_player().stats.damage_secondary)
	queue_free()
