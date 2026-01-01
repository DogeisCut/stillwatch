extends Node

const COIN_SCENE: PackedScene = preload("uid://buiy14y4dkj8e")

@onready var thirty_seconds_timer: Timer = %"30SecondsTimer"
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer

@onready var lock_sound = $LockSound
@onready var unlock_sound = $UnlockSound
@onready var music = $Music

enum GameStates {
	TITLE,
	PRE_WAVE_SETUP,
	FIGHTING_WAVE,
	DEAD
}

func change_game_state(new_state: GameStates):
	# Exit
	match game_state:
		GameStates.TITLE:
			pass
		GameStates.PRE_WAVE_SETUP:
			pass
		GameStates.FIGHTING_WAVE:
			difficulty += 1 
			enemy_spawn_timer.stop()
			enemy_spawn_timer.wait_time = 5.0 / (float(difficulty + 1) ** 0.5)
	# Enter
	game_state = new_state
	match game_state:
		GameStates.TITLE:
			music.play()
		GameStates.PRE_WAVE_SETUP:
			thirty_seconds_timer.start()
			unlock_sound.play()
		GameStates.FIGHTING_WAVE:
			lock_sound.play()
			thirty_seconds_timer.start()
			enemy_spawn_timer.start()
		GameStates.DEAD:
			music.stop()
			await get_tree().create_timer(5).timeout
			change_game_state(GameStates.TITLE)
			get_tree().change_scene_to_file("uid://byvdrfuvos8sc")
			difficulty = 0
			score = 0
			coins = 100
			current_upgrades = {
				UpgradesList.CRATE: 0,
				UpgradesList.SHOOT_SPEED: 0,
				UpgradesList.TURRET: 0,
				UpgradesList.AUTO_TURRET: 0
			} 
			await get_tree().physics_frame
			await get_tree().physics_frame
			#idk why its evil
			init.call_deferred()

func _physics_process(_delta: float) -> void:
	match game_state:
		GameStates.TITLE:
			pass
		GameStates.PRE_WAVE_SETUP:
			enemy_spawn_timer.stop()
			if thirty_seconds_timer.is_stopped():
				change_game_state(GameStates.FIGHTING_WAVE)
		GameStates.FIGHTING_WAVE:
			if thirty_seconds_timer.is_stopped():
				change_game_state(GameStates.PRE_WAVE_SETUP)
				for enemy: Enemy in get_tree().get_nodes_in_group("enemy"):
					enemy.kill()
			if enemy_spawn_timer.is_stopped():
				enemy_spawn_timer.start()

var game_state: GameStates = GameStates.TITLE: 
	set(to):
		game_state = to
		game_state_changed.emit()

signal score_changed()
signal coins_changed()
signal difficulty_changed()
signal game_state_changed()

@export var score: int = 0: 
	set(to):
		score = to
		score_changed.emit()

@export var coins: int = 100: 
	set(to):
		coins = to
		coins_changed.emit()

@export var difficulty: int = 0:
	set(to):
		difficulty = to
		difficulty_changed.emit()

enum UpgradesList {
	CRATE,
	SHOOT_SPEED,
	TURRET,
	AUTO_TURRET,
}

@export var current_upgrades: Dictionary[UpgradesList, int] = {
	UpgradesList.CRATE: 0,
	UpgradesList.SHOOT_SPEED: 0,
	UpgradesList.TURRET: 0,
	UpgradesList.AUTO_TURRET: 0
} 

func _ready():
	init.call_deferred()

func init():
	score_changed.emit()
	coins_changed.emit()
	difficulty_changed.emit()
