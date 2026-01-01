extends Node2D
class_name Turret

@onready var shoot_timer = %ShootTimer

@export var try_shoot: bool = false
@export var shoot_order: Array[Barrel]
@export var position_owner: Node2D

@export var base_shoot_speed: float = 0.5

var alternation: int = 0

func _process(_delta):	
	shoot_timer.wait_time = base_shoot_speed / ((Game.current_upgrades[Game.UpgradesList.SHOOT_SPEED] + 1) ** 0.5)
	if try_shoot:
		if shoot_timer.is_stopped():
			shoot_timer.start()
	else:
		shoot_timer.stop()

func _on_shoot_timer_timeout():
	alternation += 1
	alternation = wrap(alternation, 0, shoot_order.size())
	shoot_order[alternation].shoot()
