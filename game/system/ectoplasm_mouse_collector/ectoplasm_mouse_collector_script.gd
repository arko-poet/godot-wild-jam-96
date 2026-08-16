class_name EctoplasmMouseCollector
extends Area2D


@onready var range: CollisionShape2D = %Range

@export var range_value: float = 1.0


func _ready() -> void:
	set_range(range_value)


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()


func set_range(value: float) -> void:
	range.scale = Vector2(value, value)
