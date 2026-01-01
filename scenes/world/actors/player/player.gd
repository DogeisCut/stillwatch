extends CharacterBody2D
class_name Player

@export var move_speed: float = 2000
@export var accel: float = 10
@export var turret: Turret

@onready var lock = $Lock
@onready var death_sound = %DeathSound
@onready var animation_player = %AnimationPlayer

const TURRET_MAP: Dictionary[int, PackedScene] = {
	1: preload("uid://cxdw3chjmk7ty"),
	2: preload("uid://dhrr4hfjmh8u5"),
	3: preload("uid://d2s1d5hhiwg0f"),
	4: preload("uid://cfdurdodwb0le"),
	5: preload("uid://cgbcdbdaoq1oc")
}

var current_turret_level: int = 0

func swap_turret(to: PackedScene):
	if turret:
		turret.queue_free()
	var new_turret: Turret = to.instantiate()
	add_child(new_turret)
	new_turret.position_owner = self
	turret = new_turret

func _process(delta):
	if current_turret_level != Game.current_upgrades[Game.UpgradesList.TURRET] + 1:
		current_turret_level = Game.current_upgrades[Game.UpgradesList.TURRET] + 1
		swap_turret(TURRET_MAP[current_turret_level])
	if Game.game_state == Game.GameStates.TITLE || Game.game_state == Game.GameStates.DEAD:
		turret.try_shoot = false
		return
	lock.visible = Game.game_state != Game.GameStates.PRE_WAVE_SETUP
	if Game.game_state == Game.GameStates.PRE_WAVE_SETUP:
		velocity += Input.get_vector("left", "right", "up", "down") * move_speed * delta
	velocity = lerp(velocity, Vector2.ZERO, accel * delta)
	
	turret.look_at(get_global_mouse_position())
	turret.try_shoot = Input.is_action_pressed("shoot")
	
	move_and_slide()

func _on_hitbox_body_entered(body):
	if body is Enemy:
		death_sound.play()
		Game.change_game_state(Game.GameStates.DEAD)
		animation_player.play("death")
