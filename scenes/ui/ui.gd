extends CanvasLayer

@onready var game_ui = %GameUI
@onready var time = %Time
@onready var score = %Score
@onready var coins = %Coins
@onready var wave = %Wave
@onready var phase = %Phase

@onready var title_ui = %TitleUI

@onready var shop_ui = %ShopUI

func _ready():
	shop_ui.hide()
	game_ui.hide()
	title_ui.show()
	Game.score_changed.connect(_on_score_changed)
	Game.coins_changed.connect(_on_coins_changed)
	Game.difficulty_changed.connect(_on_difficulty_changed)
	Game.game_state_changed.connect(_on_game_state_changed)

func _on_score_changed() -> void:
	score.text = str(Game.score)

func _on_coins_changed() -> void:
	coins.text = str(Game.coins)

func _on_game_state_changed() -> void:
	match Game.game_state:
		Game.GameStates.TITLE:
			game_ui.hide()
			title_ui.show()
			shop_ui.hide()
			phase.text = "Title"
		Game.GameStates.PRE_WAVE_SETUP:
			shop_ui.show()
			game_ui.show()
			title_ui.hide()
			phase.text = "Setup"
		Game.GameStates.FIGHTING_WAVE:
			shop_ui.hide()
			game_ui.show()
			title_ui.hide()
			phase.text = "Fighting"
		Game.GameStates.DEAD:
			phase.text = "Dead :("

func _on_difficulty_changed():
	wave.text = str(Game.difficulty)

func _process(_delta: float) -> void:
	time.text = str(int(ceil(Game.thirty_seconds_timer.time_left)))
	match Game.game_state:
		Game.GameStates.TITLE:
			if Input.is_action_just_pressed("shoot"):
				Game.change_game_state(Game.GameStates.PRE_WAVE_SETUP)

func _on_skip_timer_button_down():
	Game.change_game_state(Game.GameStates.FIGHTING_WAVE)
