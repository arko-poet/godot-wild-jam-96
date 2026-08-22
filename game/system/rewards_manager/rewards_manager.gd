class_name RewardsManager
extends Node

var reward

func calculate_reward(time_estimation:float, time_left :float, current_wave:int) -> int:
	
	var a = calculate_reward_based_on_time_left(time_estimation, time_left)
	var b = calculate_reward_based_on_current_wave(current_wave)
	var c = calculate_reward_based_on_towers()
	
	reward = a*b +c
	return reward

func calculate_reward_based_on_time_left(time_estimation:float, time_left:float) -> float:
	if time_estimation <= 0:
		return 0.0

	var ratio : float = clamp(time_left / time_estimation, 0.0, 1.0)
	return sqrt(ratio)

func calculate_reward_based_on_current_wave(current_wave:int)->int:
	return 50.0 + (current_wave * 25.0)

func calculate_reward_based_on_towers():
	# Fetch towers from Group "Towers" and do calculations as needed here
	return 0
