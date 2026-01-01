extends ShopButton

func price_function(times_purchased: int) -> int:
	return 25 * (times_purchased + 1)

func on_purchase_function(times_purchased: int) -> void:
	Game.current_upgrades[Game.UpgradesList.CRATE] = times_purchased

func get_upgrade_text() -> String:
	return "Buy a Crate"

func get_cant_upgrade() -> bool:
	return total_times_purchased >= 30
