extends CharacterBody2D
class_name Enemy

const ENEMY_DEFEAT_EFFECT = preload("uid://p8s1dcskb5l6")

@export var movement_speed: float = 1000
@export var accel: float = 10
@export var hit_knockback: float = -500
@export var hit_score: int = 3
@export var kill_score: int = 35
@export var hit_coins: int = 2
@export var kill_coins: int = 8

@export var max_health: int = 3
@export var health: int = 3

@onready var navigation_agent_2d = $NavigationAgent2D
@onready var hit_sound = %HitSound

func _hit_by_projectile(projectile: PlayerBullet):
	velocity -= projectile.global_transform.basis_xform(Vector2.RIGHT) * hit_knockback
	health -= 1
	Game.score += hit_score
	hit_sound.play()
	for i in range(hit_coins): #+ floor(Game.difficulty/3.0)
		spawn_coin.call_deferred()
	if health <= 0: 
		kill()

func kill():
	Game.score += kill_score
	for i in range(kill_coins):
		spawn_coin.call_deferred()
	var effect = ENEMY_DEFEAT_EFFECT.instantiate()
	add_sibling(effect)
	effect.global_position = global_position
	queue_free()

func spawn_coin():
	var coin: Coin = Game.COIN_SCENE.instantiate()
	add_sibling(coin)
	coin.global_position = global_position
	coin.global_position += (Vector2.UP*randf_range(1.0, 10.0)).rotated(randf_range(0, PI*2))
	coin.apply_impulse((Vector2.UP*4000.0).rotated(randf_range(0, PI*2)))

func _ready():
	navigation_agent_2d.path_desired_distance = 4.0
	navigation_agent_2d.target_desired_distance = 4.0
	max_health += floor(Game.difficulty/3.0)
	health += floor(Game.difficulty/3.0)

func _physics_process(delta: float) -> void: 
	scale = Vector2.ONE * lerp(0.5, 1.0, float(health) / float(max_health))
	
	if Game.game_state != Game.GameStates.DEAD:
		navigation_agent_2d.target_position = get_tree().get_nodes_in_group("player")[0].global_position

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent_2d.get_next_path_position()
	
	if Game.game_state != Game.GameStates.DEAD:
		velocity += current_agent_position.direction_to(next_path_position) * (movement_speed + (Game.difficulty * 100)) * delta
	velocity = lerp(velocity, Vector2.ZERO, accel * delta)
	move_and_slide()
