class_name EnemyContract
extends RefCounted

# This is a simple interface meant to provide context to the tower towards a specific mob.
# This should be edited as required after the mobs are completed. 
var mob: Node2D

func _init(mob_node: Node2D) -> void:
	mob = mob_node

var health: float:
	get:
		return mob.health

var speed: float:
	get:
		return mob.speed

var path_progress: float:
	get:
		return mob.path_progress

var global_position: Vector2:
	get:
		return mob.global_position

# Update this with the proper function that makes the mob take damage in the actual mob class.
func take_damage(amount: float) -> void:
	mob.take_damage(amount)
