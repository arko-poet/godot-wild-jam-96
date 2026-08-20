class_name Level extends Node2D

signal core_damaged(damage:int)

@onready var path_layer: PathLayer = %PathLayer
@onready var mob_spawner: MobSpawner = %MobSpawner
@onready var tower_placement_controller: TowerPlacementController = $TowerPlacementController

var _path: Array[Vector2i]

func _ready() -> void:
	mob_spawner.spawn_ghost_signal.connect(_on_spawn_ghost_signal)
	mob_spawner.ghost_spawned.connect(_on_ghost_spawned)

func start_wave( current_wave: int )->void:
	mob_spawner.start()
	mob_spawner.set_current_wave(current_wave)


func get_number_of_waves() -> int:
	return mob_spawner.waves.size()


func _on_ghost_spawned( ghost:Mob )->void:
	
	ghost.mob_reached_end_of_path.connect(_on_mob_reached_end_of_path)

func _on_spawn_ghost_signal()->void:
	_path = path_layer.build_path()
	mob_spawner.spawn_ghost( _path )


func _on_mob_reached_end_of_path(damage_to_core:int) -> void:
	core_damaged.emit(damage_to_core)

func _start_building_placement(tower_resource: TowerResource):
	tower_placement_controller.start_placement(tower_resource)
