class_name MobSpawner extends Node2D


signal spawn_ghost_signal()
signal ghost_spawned( ghost: Mob )

@export var ghost_mob_scene: PackedScene

@export var waves: Array[ WaveResource ]

@onready var ghost_spawner_timer: Timer = %GhostSpawnerTimer
@onready var path_layer: PathLayer = %PathLayer

var _current_mob_resource: MobResource
var _current_batch_index: int = 0


var _current_wave: int = 0
var _ghost_spawn_count: int 
var _active_ghosts: Array[ Mob ]

func _ready() -> void:
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

func spawn_ghost(path: Array[Vector2i]) -> void:

	if path.is_empty():
		push_error("[MobSpawner] Cannot spawn ghost. Path is empty.")
		return


	var world_path: Array[Vector2] = []

	for tile in path:
		var world_position := path_layer.to_global(
			path_layer.map_to_local(tile)
		)

		world_path.append(world_position)


	var wave_resource: WaveResource = waves[_current_wave]

	var mob_resources: Array[MobResource] = wave_resource.ghosts.keys()

	if _current_mob_resource == null:

		if _current_batch_index >= mob_resources.size():
			print("[MobSpawner] Finished spawning wave.")
			_stop()
			return

		_current_mob_resource = mob_resources[_current_batch_index]

		_ghost_spawn_count = wave_resource.ghosts[
			_current_mob_resource
		]

	var spawn: Mob = ghost_mob_scene.instantiate()

	spawn.data = _current_mob_resource
	spawn.global_position = world_path[0]

	spawn.remove_from_manager_pool.connect(
		_on_ghost_mob_died
	)

	spawn.set_difficulty(_current_wave)

	add_child(spawn)
	_active_ghosts.append(spawn)
	ghost_spawned.emit(spawn)

	spawn.set_up_path(world_path)

	_ghost_spawn_count -= 1
	
	if _ghost_spawn_count <= 0:

		_current_mob_resource = null
		_current_batch_index += 1


		# Check if there are more mob types
		if _current_batch_index >= mob_resources.size():
			
			_stop()




func _on_ghost_spawner_timeout() -> void:
	spawn_ghost_signal.emit()
