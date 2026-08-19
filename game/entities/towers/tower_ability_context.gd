class_name TowerAbilityContext
extends RefCounted


var tower: Tower
var power: float
var targets: Array[EnemyContract]
var charge_status : Enums.ChargeType
var vfx_parent : Node

func _init(
	origin_tower: Tower,
	ability_power: float,
	ability_targets: Array[EnemyContract],
	charging_status: Enums.ChargeType,
	selected_vfx_parent : Node
) -> void:
	tower = origin_tower
	power = ability_power
	targets = ability_targets
	charge_status = charge_status
	vfx_parent = selected_vfx_parent
