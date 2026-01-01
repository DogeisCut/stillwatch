extends ShopButton

func price_function(times_purchased: int) -> int:
	return 300 * (times_purchased + 1)

func on_purchase_function(times_purchased: int) -> void:
	Game.current_upgrades[Game.UpgradesList.TURRET] = times_purchased

func get_upgrade_text() -> String:
	return "Upgrade Your Turret"

func get_cant_upgrade() -> bool:
	return total_times_purchased >= 4
