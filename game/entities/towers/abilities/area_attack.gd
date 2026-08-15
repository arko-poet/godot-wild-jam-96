class_name AreaAttack
extends TowerAbility


@export var damage: float = 10.0


func get_target_count() -> int:
	return -1


func activate(
	context: TowerAbilityContext,
	targets: Array[EnemyContract]
) -> void:

	for target in targets:
		target.take_damage(
			damage * context.power
		)
