class_name MobSpawner extends Node2D


signal spawn_ghost_signal()


@export var ghost_mobs: PackedScene

@onready var ghost_spawner_timer: Timer = %GhostSpawnerTimer
@onready var path_layer: PathLayer = %PathLayer


func _ready() -> void:
	ghost_spawner_timer.timeout.connect(_on_ghost_spawner_timeout)


func _on_ghost_spawner_timeout() -> void:
	spawn_ghost_signal.emit()


func spawn_ghost(path: Array[Vector2i]) -> Mob:

	if path.is_empty():
		push_error("[MobSpawner] Cannot spawn ghost. Path is empty.")
		return


	var world_path: Array[Vector2] = []

	for tile in path:
		var world_position := path_layer.to_global(
			path_layer.map_to_local(tile)
		)

		world_path.append(world_position)



	var spawn: Mob = ghost_mobs.instantiate()

	spawn.global_position = world_path[0]

	add_child(spawn)

	spawn.set_up_path(world_path)
	
	return spawn
