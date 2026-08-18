extends Node


func get_scaling_data(level_reached:int, tower_resource: TowerResource) -> TowerUpgradeResource:
	# Later on we might want to make things a bit more complicated, adding controls and 
	# letting the player choose between upgrades. When that happens this function could 
	# orchestrate the required calls with the game. 
	
	# For now we simply use the TowerUpgradeResource found in the TowerResource for the required level.
	var index = level_to_index(level_reached)
	if index < tower_resource.upgrade_path.size():
		return tower_resource.upgrade_path[index]
	else:
		# MAX LEVEL REACHED. 
		return # Nothing.

# Considering that towers start at Lvl 1.
# The Upgrade Path declares on slot [0] the upgrades for Lvl 2.
# As such when reaching Lvl 2 we use this function to easily fetch the right index.
func level_to_index(level_reached:int):
	return level_reached-2
