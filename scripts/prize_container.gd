extends Node2D
 
func _ready():
	$Item.global_scale = Vector2.ZERO
	$Item/PickupArea.monitoring = false
	$Item/PickupArea.monitorable = false
	
func activate():
	$Item.global_scale = Vector2.ONE
	$Item/PickupArea.monitoring = true
	$Item/PickupArea.monitorable = true
