class_name RubbingDetector
extends Node2D


@export_category("Rubbing")
@export var minimum_movement := 2.0
@export var outside_grace_period := 0.5

@export_category("Intensity")
@export var ideal_direction_change_rate := 1800.0

var is_rubbing := false
var is_mouse_inside := false

var outside_time := 0.0

var previous_mouse_position := Vector2.ZERO
var previous_movement := Vector2.ZERO

var directional_change_in_window := 0.0
var directional_change_rate := 0.0

var measurement_window := 0.25
var measurement_time := 0.0

var rubbing_time := 0.0

var rubbing_intensity := 0.0


func start_rubbing() -> void:
	if is_rubbing:
		return

	is_rubbing = true

	is_mouse_inside = true
	outside_time = 0.0

	previous_mouse_position = get_global_mouse_position()
	previous_movement = Vector2.ZERO

	directional_change_in_window = 0.0
	directional_change_rate = 0.0
	measurement_time = 0.0

	rubbing_time = 0.0
	rubbing_intensity = 0.0


func stop_rubbing() -> void:
	if not is_rubbing:
		return

	is_rubbing = false
	previous_movement = Vector2.ZERO

	directional_change_rate = 0.0
	rubbing_intensity = 0.0


func set_mouse_inside(value: bool) -> void:
	is_mouse_inside = value

	if value:
		outside_time = 0.0

		if is_rubbing:
			previous_mouse_position = get_global_mouse_position()
			previous_movement = Vector2.ZERO

			# "[RubbingDetector] Mouse returned — resuming sampling."
	#else:
		#"[RubbingDetector] Mouse exited."


func _physics_process(delta: float) -> void:
	if not is_rubbing:
		return

	_process_mouse_boundary(delta)

	if not is_rubbing:
		return

	_process_mouse_movement(delta)

	rubbing_time += delta

	_update_directional_change(delta)


func _process_mouse_boundary(delta: float) -> void:
	if is_mouse_inside:
		outside_time = 0.0
		return

	outside_time += delta

	if outside_time >= outside_grace_period:
		stop_rubbing()


func _process_mouse_movement(_delta: float) -> void:
	var current_mouse_position := get_global_mouse_position()
	var movement := current_mouse_position - previous_mouse_position
	var movement_distance := movement.length()

	if movement_distance >= minimum_movement:
		_process_movement(movement)

	previous_mouse_position = current_mouse_position


func _process_movement(movement: Vector2) -> void:
	if previous_movement.length() < minimum_movement:
		previous_movement = movement
		return

	var previous_direction := previous_movement.normalized()
	var current_direction := movement.normalized()

	var direction_change : float = abs(
		previous_direction.angle_to(current_direction)
	)

	var direction_change_degrees := rad_to_deg(direction_change)

	directional_change_in_window += direction_change_degrees

	previous_movement = movement


func _update_directional_change(delta: float) -> void:
	measurement_time += delta

	if measurement_time < measurement_window:
		return

	directional_change_rate = (
		directional_change_in_window / measurement_time
	)

	rubbing_intensity = get_rubbing_intensity()
	directional_change_in_window = 0.0
	measurement_time = 0.0


func get_rubbing_intensity() -> float:
	return clamp(
		directional_change_rate / ideal_direction_change_rate,
		0.0,
		1.0
	)
