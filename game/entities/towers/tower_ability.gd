class_name TowerAbility
extends Resource

@export var vfx: PackedScene

func requires_targets() -> bool:
	return true

# -1 is a Special Value used to targets every mob in range.
func get_target_count() -> int:
	return 1


func activate(
	context : TowerAbilityContext
) -> void:
	push_error(
		"TowerAbility.activate() was not implemented."
	)
