class_name TowerPlacementController
extends Node2D

signal confirmation_requested(
	tower: TowerResource
)

signal placement_cancelled

@export_category("References")
@export var ground_layer: TileMapLayer
@export var path_layer: TileMapLayer
@export var towers_container: Node2D

var occupied_cells: Dictionary = {}
var awaiting_confirmation: bool = false
const TOWER_SCENE := preload("res://game/entities/towers/Tower.tscn")

var selected_tower: TowerResource
var preview_tower: Tower

var current_cell: Vector2i
var placement_valid: bool = false

func _ready() -> void:
	if ground_layer == null:
		push_error("TowerPlacementController: Ground Layer is not assigned.")

	if path_layer == null:
		push_error("TowerPlacementController: Path Layer is not assigned.")

	if towers_container == null:
		push_error("TowerPlacementController: Towers Container is not assigned.")


func _process(_delta: float) -> void:
	if selected_tower == null:
		return

	update_preview()


func _unhandled_input(event: InputEvent) -> void:
	if selected_tower == null:
		return

	if event is InputEventMouseButton and event.pressed:

		if event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_placement()

		elif event.button_index == MOUSE_BUTTON_LEFT:
			attempt_placement()

func start_placement(tower: TowerResource) -> void:
	selected_tower = tower

	create_preview()
	

func create_preview() -> void:
	if preview_tower != null:
		preview_tower.queue_free()

	preview_tower = TOWER_SCENE.instantiate() as Tower
	preview_tower.data = selected_tower
	add_child(preview_tower)

	preview_tower.set_preview_mode(true)

func update_preview() -> void:
	if awaiting_confirmation:
		return
	var mouse_position := get_global_mouse_position()

	current_cell = ground_layer.local_to_map(
		ground_layer.to_local(mouse_position)
	)

	var snapped_position := ground_layer.to_global(
		ground_layer.map_to_local(current_cell)
	)

	preview_tower.global_position = snapped_position
		
	placement_valid = is_valid_placement(current_cell)

	update_preview_visual()

func is_valid_placement(cell: Vector2i) -> bool:
	for footprint_cell in preview_tower.footprint:
		var grid_cell := footprint_cell + cell
	
		if not is_ground(grid_cell):
			return false

		if is_path(grid_cell):
			return false

		if is_occupied(grid_cell):
			return false

	return true

func is_ground(cell: Vector2i) -> bool:
	return ground_layer.get_cell_source_id(cell) != -1


func is_path(cell: Vector2i) -> bool:
	return path_layer.get_cell_source_id(cell) != -1


func is_occupied(cell: Vector2i) -> bool:
	return occupied_cells.has(cell)

func update_preview_visual() -> void:
	if placement_valid:
		preview_tower.set_preview_color(
			Color(0.3, 1.0, 0.3, 0.5)
		)
	else:
		preview_tower.set_preview_color(
			Color(1.0, 0.2, 0.2, 0.5)
		)

func cancel_placement() -> void:
	if preview_tower != null:
		preview_tower.queue_free()
		preview_tower = null

	selected_tower = null
	placement_valid = false

func attempt_placement() -> void:
	if not placement_valid:
		return

	show_confirmation()
	
func show_confirmation() -> void:
	awaiting_confirmation = true
	confirmation_requested.emit(selected_tower)
	
func confirm_placement() -> void:
	if not awaiting_confirmation:
		return

	if not placement_valid:
		cancel_confirmation()
		return

	

	var tower := TOWER_SCENE.instantiate() as Tower
	tower.data = selected_tower
	tower.preview_mode = false
	towers_container.add_child(tower)
	
	tower.global_position = get_cell_world_position(current_cell)

	occupied_cells[current_cell] = tower
	
	stop_placement()

func cancel_confirmation() -> void:
	awaiting_confirmation = false

func stop_placement() -> void:
	if preview_tower != null:
		preview_tower.queue_free()
		preview_tower = null

	selected_tower = null
	placement_valid = false
	awaiting_confirmation = false

func get_cell_world_position(cell: Vector2i) -> Vector2:
	return ground_layer.to_global(
		ground_layer.map_to_local(cell)
	)
