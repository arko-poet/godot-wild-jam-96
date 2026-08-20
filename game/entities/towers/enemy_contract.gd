class_name EnemyContract
extends RefCounted

# This is a simple interface meant to provide context to the tower towards a specific mob.
# This should be edited as required after the mobs are completed. 
var mob: Mob

func _init(mob_node: Mob) -> void:
	mob = mob_node

var health: float:
	get:
		return mob.health

var speed: float:
	get:
		return mob.speed

var path_progress: int:
	get:
		return mob.path_index

var global_position: Vector2:
	get:
		return mob.global_position

# Update this with the proper function that makes the mob take damage in the actual mob class.
func take_damage(damage: DamagePacket) -> void:
	if mob:
		mob.take_damage(damage)
