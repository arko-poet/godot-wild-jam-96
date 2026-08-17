class_name MobSpawner extends Node2D

signal spawn_ghost_signal()
signal ghost_spawned(ghost: Mob)

@export var ghost_mob_scene: PackedScene
@export var waves: Array[WaveResource]

@onready var ghost_spawner_timer: Timer = %GhostSpawnerTimer
@onready var path_layer: PathLayer = %PathLayer

var _current_mob_resource: MobResource
var _current_batch_index: int = 0
var _current_wave: int = 0
var _ghost_spawn_count: int = 0
var _active_ghosts: Array[Mob] = []


func _ready() -> void:
	ghost_spawner_timer.timeout.connect(_on_ghost_spawner_timeout)
	Event.next_wave_trigered_signal.connect(_start)


func _stop() -> void:
	ghost_spawner_timer.stop()


func _start(current_wave: int) -> void:
	if current_wave < 0 or current_wave >= waves.size():
		push_error(
			"[MobSpawner] Invalid wave index: %d" % current_wave
		)
		return

	_current_wave = current_wave
	_current_batch_index = 0
	_current_mob_resource = null
	_ghost_spawn_count = 0
	_active_ghosts.clear()

	ghost_spawner_timer.start()


func _on_ghost_mob_died(ghost_mob: Mob) -> void:
	_active_ghosts.erase(ghost_mob)

	if _active_ghosts.is_empty():
		Event.wave_ended()


func spawn_ghost(path: Array[Vector2i]) -> void:
	if path.is_empty():
		push_error("[MobSpawner] Cannot spawn ghost. Path is empty.")
		return

	if _current_wave < 0 or _current_wave >= waves.size():
		push_error("[MobSpawner] Invalid current wave.")
		return

	var current_wave_resource: WaveResource = waves[_current_wave]

	var mob_resources: Array[MobResource] = \
		current_wave_resource.ghosts.keys()

	# No more mob types in this wave.
	if _current_batch_index >= mob_resources.size():
		_stop()
		return

	# Start a new batch.
	if _current_mob_resource == null:
		_current_mob_resource = mob_resources[_current_batch_index]

		_ghost_spawn_count = current_wave_resource.ghosts[
			_current_mob_resource
		]

	# Build world-space path.
	var world_path: Array[Vector2] = []

	for tile in path:
		var world_position := path_layer.to_global(
			path_layer.map_to_local(tile)
		)

		world_path.append(world_position)

	if world_path.is_empty():
		push_error("[MobSpawner] World path is empty.")
		return

	# Spawn ghost.
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

	# One ghost from this batch has been spawned.
	_ghost_spawn_count -= 1

	# Batch is complete.
	if _ghost_spawn_count <= 0:
		_current_mob_resource = null
		_current_batch_index += 1

		# Entire wave has been spawned.
		if _current_batch_index >= mob_resources.size():
			_stop()


func _on_ghost_spawner_timeout() -> void:
	ghost_spawned.emit()
