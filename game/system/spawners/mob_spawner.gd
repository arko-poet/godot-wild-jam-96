class_name MobSpawner extends Node2D


signal spawn_ghost_signal()

@export var ghost_mobs: Array[ MobWaveResource ]


@onready var path_layer: PathLayer = %PathLayer


var _current_wave: int = 0
var _active_ghosts: Array[ Mob ]

func _ready() -> void:
	Event.next_wave_trigered_signal.connect(_start)


func _start( current_wave: int )->void:
	_current_wave = current_wave
	spawn_ghost_signal.emit()

func _on_ghost_mob_died( ghost_mob: Mob )->void:
	_active_ghosts.erase(ghost_mob)
	
	if _active_ghosts.size() == 0:
		Event.wave_ended()

func spawn_ghost(path: Array[Vector2i]) -> Mob:
	print("spoa")
	var ghost_wave_index: int = _current_wave - 1

	if ghost_wave_index >= ghost_mobs.size():
		push_error("[MobSpawner] Wave index is out of range.")
		return null

	var wave: MobWaveResource = ghost_mobs[ghost_wave_index]

	if path.is_empty():
		push_error("[MobSpawner] Cannot spawn ghost. Path is empty.")
		
		## TODO - will create a functiuon to handle infinate spawn generation after initial custom waves
		## have been all used - 
		return null

	var world_path: Array[Vector2] = []

	for tile in path:
		var world_position := path_layer.to_global(
			path_layer.map_to_local(tile)
		)

		world_path.append(world_position)

	for spawn_slot in wave.enemy_mobs:

		var spawn_scene: PackedScene = wave.enemy_mobs[spawn_slot]
		var spawn: Mob = spawn_scene.instantiate()
		

		var spawn_index: int = spawn_slot

		if spawn_index >= world_path.size():
			push_error(
				"[MobSpawner] Spawn slot %s does not have a corresponding path position."
				% spawn_slot
			)
			continue

		spawn.global_position = world_path[spawn_index]

		spawn.remove_from_manager_pool.connect(
			_on_ghost_mob_died
		)

		spawn.set_difficulty(_current_wave)

		add_child(spawn)
		_active_ghosts.append(spawn)

		spawn.set_up_path(world_path)
		

	return null
