class_name BaseHomingVFX
extends Node2D

signal vfx_completed

const PRESET_SPEED: float = 500.0
var current_speed :float = 0

var direction = Vector2(0,0)
var target_node :Node2D

func start(start_position:Vector2, target: Node2D):
	global_position = start_position
	current_speed = PRESET_SPEED
	target_node = target	

func _process(delta: float) -> void:
	if not is_instance_valid(target_node):
		queue_free()
		return
	
	var target_position := target_node.global_position
	var distance := global_position.distance_to(target_position)
	var movement := current_speed * delta
	
	# We would reach or overshoot the target this frame.
	if movement >= distance:
		global_position = target_position
		vfx_completed.emit()
		queue_free()
		return
	
	update_direction()
	global_position += direction * movement
	
	

func update_direction():
	direction = global_position.direction_to(target_node.global_position)
	
