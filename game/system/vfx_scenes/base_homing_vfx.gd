class_name BaseHomingVFX
extends Node2D

signal vfx_completed

const PRESET_SPEED: float = 1000.0
const CONTACT_DISTANCE_SQR: float = 64.0 # Just a small value to make the bullet think it has reached it's destination
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
	update_direction()
	global_position += direction*current_speed*delta
	
	if check_for_completion():
		vfx_completed.emit()
		queue_free()

func update_direction():
	direction = global_position.direction_to(target_node.global_position)
	
func check_for_completion():
	return target_node.global_position.distance_squared_to(global_position) < CONTACT_DISTANCE_SQR
