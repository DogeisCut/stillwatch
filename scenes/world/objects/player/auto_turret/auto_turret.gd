extends RigidBody2D
class_name AutoTurret

var enemies: Array[Enemy]

@export var turret: Turret

func _on_area_2d_body_entered(body):
	if body is Enemy:
		enemies.append(body)

func _on_area_2d_body_exited(body):
	if body is Enemy:
		enemies.erase(body)

func _physics_process(_delta):
	if enemies.is_empty():
		turret.try_shoot = false
		return

	var closest_enemy: Enemy = null
	var closest_enemy_distance_squared := INF

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var distance_squared := turret.global_position.distance_squared_to(enemy.global_position)
		if distance_squared < closest_enemy_distance_squared:
			closest_enemy_distance_squared = distance_squared
			closest_enemy = enemy

	if closest_enemy:
		turret.look_at(closest_enemy.global_position)
		turret.try_shoot = true
