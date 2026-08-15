class_name Mob extends Node2D

@onready var mob_body: MobBody = %MobBody


func _ready() -> void:
	mob_body.mob_reached_end_of_path.connect(_on_mob_reached_end_of_path)
	mob_body.hp_reduced_to_zero.connect(_mob_die)
	
func set_up_path(path: Array[Vector2]) -> void:
	mob_body.path = path
	mob_body.path_index = 0


	if mob_body.path.is_empty():
		push_error("[Mob] Received empty path.")
		return
	

func _on_mob_reached_end_of_path()->void:
	
	_mob_die()
	

func _mob_die()->void:
	
	queue_free()
