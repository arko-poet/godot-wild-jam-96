class_name EctoplasmSpawner
extends Node2D


const ECTOPLASM_SCENE = preload("uid://dk80bjowjtg8w")


func _ready() -> void:
	randomize()
	var mob: Mob = get_parent()
	mob.mob_killed.connect(_on_mob_killed)


## For varied offest in spawn location
@export var spawn_radius: float = 10.0


func _on_mob_killed() -> void:
	
	_spawn_ectoplasm()



func _spawn_ectoplasm()->void:
	
	var parent: Mob = get_parent()
	var ectoplasm: Ectoplasm = ECTOPLASM_SCENE.instantiate()
	var offset := Vector2(
		randf_range(-spawn_radius, spawn_radius),
		randf_range(-spawn_radius, spawn_radius)
	)
	
	ectoplasm.global_position = global_position + offset
	ectoplasm.ectoplasm_value = parent.loot
	get_tree().current_scene.add_child(ectoplasm)
