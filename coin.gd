extends RigidBody2D
class_name Coin

var collected: bool = false

@onready var collecting_sound = %CollectingSound
@onready var collect_sound = %CollectSound
@onready var collision_shape_2d = %CollisionShape2D

func _on_hitbox_body_entered(body):
	if body is Player and not collected and Game.game_state != Game.GameStates.DEAD:
		collected = true
		var collection_start_pos: Vector2 = global_position
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_BACK)
		collecting_sound.play()
		tween.tween_method(
			func(progress_value):
				global_position = collection_start_pos.lerp(body.global_position, progress_value),
			0.0,
			1.0,
			0.2
		)
		tween.tween_callback(func():
			Game.coins += 1
			collect_sound.play()
			hide()
			await collect_sound.finished
			queue_free()
		)


func _on_physics_disable_timer_timeout():
	collision_shape_2d.disabled = true
