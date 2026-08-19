class_name TowerAbilityContext
extends RefCounted


var origin: Vector2
var power: float
var targets: Array[EnemyContract]
var charge_status : Enums.ChargeType

func _init(
	ability_origin: Vector2,
	ability_power: float,
	ability_targets: Array[EnemyContract],
	charging_status: Enums.ChargeType
) -> void:
	origin = ability_origin
	power = ability_power
	targets = ability_targets
	charge_status = charge_status
