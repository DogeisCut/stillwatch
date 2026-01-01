@abstract
extends Button
class_name ShopButton

var total_times_purchased: int

@export var purchase_audio_player: AudioStreamPlayer

@abstract func get_cant_upgrade() -> bool

@abstract func get_upgrade_text() -> String

@abstract func price_function(times_purchased: int) -> int

@abstract func on_purchase_function(times_purchased: int) -> void

func _ready():
	pressed.connect(_on_pressed)
	Game.coins_changed.connect(_on_coins_changed)
	update_text()
	update_disabled_status()

func update_text():
	text = get_upgrade_text() + "\n(" + str(price_function(total_times_purchased)) + ")"

func _on_coins_changed() -> void:
	update_disabled_status()

func update_disabled_status():
	disabled = get_cant_upgrade() || Game.coins < price_function(total_times_purchased)

func _on_pressed():
	if Game.coins >= price_function(total_times_purchased):
		Game.coins -= price_function(total_times_purchased)
		total_times_purchased += 1
		on_purchase_function(total_times_purchased)
		update_text()
		update_disabled_status()
		purchase_audio_player.play()
