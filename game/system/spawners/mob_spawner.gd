class_name MobSpawner extends Node2D


signal spawn_ghost_signal()

## TODO Will create an array of differant mob types. for now just 1 Ghost Mob
@export var ghost_mobs: PackedScene

@onready var ghost_spawner_timer: Timer = %GhostSpawnerTimer
@onready var path_layer: PathLayer = %PathLayer
@export var total_ghost_spawn_count: int = 5


## Created this variable so we can later use it to determin if we want to increase spawn count if we want to. 
## or we can use this to determin the scaling of the mob health / speed. Decided not to get into that now as
## you stated you wanted to work on this at a later time by increasiung the difficulty valriable I added to 
## Base Mob from here before its spawned. 

var _current_wave: int = 0
var _ghost_spawn_count: int 
var _active_ghosts: Array[ Mob ]

func _ready() -> void:
	_ghost_spawn_count = total_ghost_spawn_count
	ghost_spawner_timer.timeout.connect(_on_ghost_spawner_timeout)
	Event.next_wave_trigered_signal.connect(_start)

func _stop()->void:
	ghost_spawner_timer.stop()

func _start( current_wave: int )->void:
	_current_wave = current_wave
	ghost_spawner_timer.start()

func _on_ghost_mob_died( ghost_mob: Mob )->void:
	_active_ghosts.erase(ghost_mob)
	
	if _active_ghosts.size() == 0:
		Event.wave_ended()

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
	spawn.remove_from_manager_pool.connect(_on_ghost_mob_died)
	add_child(spawn)
	_active_ghosts.append(spawn)
	_ghost_spawn_count -= 1

	spawn.set_up_path(world_path)
	
	if _ghost_spawn_count <= 0:
		## Resets spawn count to total ghost span count for next wave. 
		_ghost_spawn_count = total_ghost_spawn_count
		_stop()
	return spawn



func _on_ghost_spawner_timeout() -> void:
	spawn_ghost_signal.emit()
