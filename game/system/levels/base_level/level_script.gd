class_name Level extends Node2D

signal core_damaged

@onready var path_layer: PathLayer = %PathLayer
@onready var mob_spawner: MobSpawner = %MobSpawner

var _path: Array[Vector2i]

func _ready() -> void:
	mob_spawner.spawn_ghost_signal.connect(_on_spawn_ghost_signal)


func _on_spawn_ghost_signal()->void:
	_path = path_layer.build_path()
	var mob: Mob = mob_spawner.spawn_ghost( _path )

	mob.mob_reached_end_of_path.connect(_on_mob_reached_end_of_path)
	

func _on_mob_reached_end_of_path() -> void:
	core_damaged.emit()
