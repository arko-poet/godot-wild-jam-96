class_name MobBody extends CharacterBody2D


signal mob_reached_end_of_path

@export var speed: float = 100.0


var path: Array[Vector2]
var path_index: int = 0





func _physics_process(_delta: float) -> void:

	if path_index >= path.size():
		velocity = Vector2.ZERO
		mob_reached_end_of_path.emit()
		return

	var target := path[path_index]
	var direction := global_position.direction_to(target)
	velocity = direction * speed
	move_and_slide()


	if global_position.distance_to(target) < 2.0:

		global_position = target
		path_index += 1
