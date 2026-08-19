class_name SingleTargetAttack
extends TowerAbility


@export var damage: float = 10.0

var target : EnemyContract
var built_damage_packet: DamagePacket

func get_target_count() -> int:
	return 1


func activate(
	context: TowerAbilityContext
) -> void:

	if context.targets.is_empty():
		return

	target = context.targets[0]
	var projectile: BaseHomingVFX = vfx.instantiate()
	
	context.vfx_parent.add_child(projectile)

	projectile.start(
		context.tower.global_position,
		target.mob
	)
	projectile.vfx_completed.connect(apply_effect)
	var damage_packet = DamagePacket.new()
	damage_packet.amount = damage *context.power
	damage_packet.charge_sign = Enums.ChargeType.NEUTRAL
	built_damage_packet = damage_packet
	

func apply_effect():
	target.take_damage(
		built_damage_packet
	)
	
