class_name SingleTargetAttack
extends TowerAbility


@export var damage: float = 10.0


func get_target_count() -> int:
	return 1


func activate(
	context: TowerAbilityContext
) -> void:

	if context.targets.is_empty():
		return

	var target := context.targets[0]

	target.take_damage(
		damage * context.power
	)
