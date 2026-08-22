class_name PathLayer extends TileMapLayer


@onready var start_layer: TileMapLayer = %StartLayer
@onready var end_layer: TileMapLayer = %EndLayer
@onready var crossing_layer: TileMapLayer = %CrossingLayer


var _path_tiles: Array[Vector2i]
var _end_tile: Vector2i
var _start_tile: Vector2i
var _path: Array[Vector2i]

var is_built : bool = false

func get_built_path() -> Array[Vector2i]:
	if not is_built:
		return build_path()
	else:
		return _path

func build_path() -> Array[Vector2i]:

	_path = _build_path()
	is_built = true
	return _path


## WARNING the path crossing don't work for all directions
## this is just a temporary solution to make current level work
## later we can replace this with Path2D
func _build_path() -> Array[Vector2i]:
	## Grab path tile positions.
	_path_tiles = get_used_cells()


	## Grab start and end positions.
	var start_tiles := start_layer.get_used_cells()
	var end_tiles := end_layer.get_used_cells()
	var crossing_tiles := crossing_layer.get_used_cells()


	assert(start_tiles.size() == 1, "StartLayer must have exactly one tile.")
	assert(end_tiles.size() == 1, "EndLayer must have exactly one tile.")


	_start_tile = start_tiles[0]
	_end_tile = end_tiles[0]


	## Build ordered path.
	_path.clear()

	var current_tile := _start_tile
	_path.append(current_tile)




	var directions := [
		Vector2i.LEFT,
		Vector2i.DOWN,
		Vector2i.RIGHT,
		Vector2i.UP
	]


	while current_tile != _end_tile:
		var next_tile := Vector2i.ZERO
		var found_next := false


		for direction in directions:

			var candidate = current_tile + direction

			if candidate in _path_tiles and (candidate not in _path or candidate in crossing_tiles):
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
