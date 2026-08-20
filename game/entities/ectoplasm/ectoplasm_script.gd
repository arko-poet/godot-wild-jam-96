class_name Ectoplasm
extends Node2D

enum CollectingState { MOUSE, UI, NONE }

@onready var mouse_detection: Area2D = %MouseDetection
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var animated_sprite_2d: Sprite2D = %AnimatedSprite2D

var ectoplasm_value: int = 1
var mouse_collector: EctoplasmMouseCollector
var is_collecting := false
var current_collecting_state: CollectingState = CollectingState.NONE
var ectoplasm_ui_location: Vector2
@export var move_to_mouse_speed: float = 100.0
@export var collect_speed: float = 500.0

## This is here so I can reparent the sprite to canvis layer for visuals when moving towards lable. 
var _ect_lable_ref: Control
var _ui_canvas_layer: CanvasLayer
var _is_collected: bool = false

func _ready() -> void:
	randomize()
	mouse_detection.area_entered.connect(_on_area_entered)
	_get_ui_ref()


func _get_ui_ref() -> void:
	var ectoplasm_label = get_tree().get_first_node_in_group("ectoplasm_lable")

	if not ectoplasm_label:
		print("ERROR: No ectoplasm label found")
		return

	_ect_lable_ref = ectoplasm_label

	var node = ectoplasm_label

	while node and not node is CanvasLayer:
		node = node.get_parent()

	_ui_canvas_layer = node as CanvasLayer

	if not _ui_canvas_layer:
		print("ERROR: No CanvasLayer found")
		return

	var rect = ectoplasm_label.get_global_rect()
	ectoplasm_ui_location = rect.get_center()




func _on_area_entered(area: Area2D) -> void:
	if area is EctoplasmMouseCollector:
		mouse_collector = area
		is_collecting = true
		current_collecting_state = CollectingState.MOUSE


func _process(delta: float) -> void:
	if not is_collecting:
		return

	match current_collecting_state:

		CollectingState.MOUSE:
			global_position = global_position.move_toward(
				mouse_collector.global_position,
				move_to_mouse_speed * delta
			)

			if global_position.distance_to(mouse_collector.global_position) < 0.05:
				_enter_ui_state()


		CollectingState.UI:
			global_position = global_position.move_toward(
				ectoplasm_ui_location,
				collect_speed * delta
			)

			if global_position.distance_to(ectoplasm_ui_location) < 2.0:
				_collected()


func _enter_ui_state() -> void:
	current_collecting_state = CollectingState.UI

	if _ui_canvas_layer:
		reparent(_ui_canvas_layer, true)

		reset_physics_interpolation()




func _play_idle()->void:
	animation_player.play("IDLE")

func _collected() -> void:
	if !_is_collected:
		Event.ectoplasm_collected(ectoplasm_value)
		animation_player.play("COLLECT")
		_is_collected = true

func _on_collect_animation_finished()->void:
	queue_free()
