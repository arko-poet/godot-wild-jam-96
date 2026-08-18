class_name AreaAttack
extends TowerAbility


@export var damage: float = 10.0


func get_target_count() -> int:
	return -1


func activate(
	context: TowerAbilityContext
) -> void:
	var damage_packet = DamagePacket.new()
	damage_packet.amount = damage *context.power
	damage_packet.charge_sign = Enums.ChargeType.NEUTRAL
	for target in context.targets:
		target.take_damage(
			damage_packet
		)
