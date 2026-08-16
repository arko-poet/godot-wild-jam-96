class_name PathLayer extends TileMapLayer


@onready var start_layer: TileMapLayer = %StartLayer
@onready var end_layer: TileMapLayer = %EndLayer


var _path_tiles: Array[Vector2i]
var _end_tile: Vector2i
var _start_tile: Vector2i
var _path: Array[Vector2i]


func build_path() -> Array[Vector2i]:

	_path = _build_path()
	return _path


func _build_path() -> Array[Vector2i]:

	## Grab path tile positions.
	_path_tiles = get_used_cells()


	## Grab start and end positions.
	var start_tiles := start_layer.get_used_cells()
	var end_tiles := end_layer.get_used_cells()


	assert(start_tiles.size() >= 1, "StartLayer must have at least one tile.")
	assert(end_tiles.size() == 1, "EndLayer must have exactly one tile.")


	## Sort start tiles by spawn_tile custom data.
	start_tiles.sort_custom(_sort_start_tiles_by_spawn_order)


	## The first spawn tile is the primary starting point.
	_start_tile = start_tiles[0]
	_end_tile = end_tiles[0]


	## Build ordered path.
	_path.clear()

	var current_tile := _start_tile
	_path.append(current_tile)


	var directions := [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT
	]


	while current_tile != _end_tile:

		var next_tile := Vector2i.ZERO
		var found_next := false


		for direction in directions:

			var candidate = current_tile + direction

			if candidate in _path_tiles and candidate not in _path:
				next_tile = candidate
				found_next = true
				break


		if not found_next:

			push_error(
				"[PathLayer] Could not find path from %s to %s. Current tile: %s"
				% [_start_tile, _end_tile, current_tile]
			)

			return []


		current_tile = next_tile
		_path.append(current_tile)


	return _path


# This function is was created to sort the start tiles by assending order when compared the 
# custom data assigned to each. 
func _sort_start_tiles_by_spawn_order(
	a: Vector2i,
	b: Vector2i
) -> bool:

	var a_data: TileData = start_layer.get_cell_tile_data(a)
	var b_data: TileData = start_layer.get_cell_tile_data(b)

	var a_order: int = a_data.get_custom_data("spawn_tile")
	var b_order: int = b_data.get_custom_data("spawn_tile")

	return a_order < b_order
