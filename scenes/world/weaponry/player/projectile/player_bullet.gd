extends RigidBody2D
class_name PlayerBullet

const BULLET_CRUMPLE_EFFECT = preload("uid://bw2l0nk47n0c2")

@onready var collision_shape_2d = $CollisionShape2D
@onready var sprite_2d = $Sprite2D

@export var size: float

func init():
	(collision_shape_2d.shape as CircleShape2D).radius = size/2.0
	sprite_2d.scale = Vector2.ONE * 1/64.0 * size

func _on_body_entered(body):
	if body is Enemy:
		body._hit_by_projectile(self)
	var effect = BULLET_CRUMPLE_EFFECT.instantiate()
	add_sibling(effect)
	effect.global_position = global_position
	queue_free()

func _on_lifetime_timeout():
	queue_free()
