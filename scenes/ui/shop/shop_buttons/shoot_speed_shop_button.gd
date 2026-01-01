extends ShopButton

func price_function(times_purchased: int) -> int:
	return 150 * (times_purchased + 1)

func on_purchase_function(times_purchased: int) -> void:
	Game.current_upgrades[Game.UpgradesList.SHOOT_SPEED] = times_purchased

func get_upgrade_text() -> String:
	return "Buy Faster Shoot Speed"

func get_cant_upgrade() -> bool:
	return total_times_purchased >= 10
