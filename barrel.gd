extends Node2D
class_name Barrel

@onready var visuals = %Visuals
@onready var barrel_tip = %BarrelTip
@onready var shoot_sound = %ShootSound
@onready var animation_player = %AnimationPlayer

@export var length: float = 50
@export var width: float = 20
@export var shoot_force: float = 5000
@export var bullet_scene: PackedScene
@export var turret: Turret

func _ready():
	visuals.scale = Vector2(length, width)

func shoot() -> void:
	animation_player.stop()
	var bullet: PlayerBullet = bullet_scene.instantiate()
	turret.position_owner.add_sibling(bullet)
	shoot_sound.play()
	bullet.global_position = barrel_tip.global_position
	bullet.global_rotation = global_rotation
	bullet.size = width
	bullet.apply_impulse(global_transform.basis_xform(Vector2.RIGHT) * (shoot_force + (Game.current_upgrades[Game.UpgradesList.SHOOT_SPEED] * 500)))
	bullet.init()
	animation_player.play("shoot")
