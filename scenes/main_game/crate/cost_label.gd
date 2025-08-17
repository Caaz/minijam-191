extends Label3D

func _ready() -> void:
	visibility_changed.connect(func():
		var game:MainGame = find_parent("MainGame") as MainGame
		if game.current_upgrade_mode == GlobalData.UpgradeMode.NONE:
			hide()
			return
		var crate:Crate = get_parent() as Crate
		var upgrade_cost = crate.get_upgrade_cost(game.current_upgrade_mode)
		if upgrade_cost > 0:
			text = "Cost: %d" % upgrade_cost
		else:
			text = "Max Upgrade!"
	)
