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

## This is here so I can reparent the sprite to canvis layer for visuals when moving towards lable. 
var _ect_lable_ref: Control
var _ui_canvas_layer: CanvasLayer
var _is_collected: bool = false

## For Movement to UI Movement:
var ui_start_position: Vector2
var ui_move_progress := 0.0
## Controlls the speed / time it takes for the arc to complete. 
var ui_move_duration := 0.8

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
			ui_move_progress += delta / ui_move_duration

			var t = clamp(ui_move_progress, 0.0, 1.0)

			# Smooth start/end
			var eased_t = t * t * (3.0 - 2.0 * t)

			# Main movement
			var pos := ui_start_position.lerp(
				ectoplasm_ui_location,
				eased_t
			)

			# Parabolic arc
			var arc_height := 100.0
			pos.y -= 4.0 * arc_height * t * (1.0 - t)

			global_position = pos

			if t >= 1.0:
				_collected()



func _enter_ui_state() -> void:
	current_collecting_state = CollectingState.UI
	ui_start_position = global_position
	ui_move_progress = 0.0

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
