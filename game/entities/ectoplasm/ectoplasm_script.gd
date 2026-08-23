class_name Ectoplasm
extends Node2D

enum AnimationState { IDLE, COLLECTED, SPAWN, COLLECTING } 
var _curent_animation_state: AnimationState = AnimationState.SPAWN

@onready var mouse_detection: Area2D = %MouseDetection
@onready var animated_sprite_2d: Sprite2D = %AnimatedSprite2D


## For Idle Animation
var _start_y: float
var _time: float = 0.0
var float_height: float = 5.0
var float_speed: float = 2.0

var ectoplasm_value: int = 1
var mouse_collector: EctoplasmMouseCollector
var ectoplasm_ui_location: Vector2
@export var move_to_mouse_speed: float = 100.0

## This is here so I can reparent the sprite to canvis layer for visuals when moving towards lable. 
var _ect_lable_ref: Control
var _ui_canvas_layer: CanvasLayer

## For Movement to UI Movement:
var ui_start_position: Vector2
var ui_move_progress := 0.0
## Controlls the speed / time it takes for the arc to complete. 
var ui_move_duration := 0.8

func _ready() -> void:
	randomize()

	mouse_detection.area_entered.connect(_on_area_entered)
	_get_ui_ref()
	_play_spawn_animation()


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
		_enter_collecting_state()


func _process(delta: float) -> void:
	match _curent_animation_state:
		AnimationState.IDLE:
			_time += delta
			
			position.y = _start_y + sin(_time * float_speed) * float_height

		AnimationState.COLLECTING:
			
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

func _play_spawn_animation() -> void:
	
	scale = Vector2(0.1, 0.1)
	modulate.a = 0.0
	
	var tween := create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "modulate:a", 1.0, 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	
	await tween.finished
	_start_y = position.y
	_curent_animation_state = AnimationState.IDLE


func _enter_collecting_state() -> void:
	_curent_animation_state = AnimationState.COLLECTING
	ui_start_position = global_position
	ui_move_progress = 0.0

	if _ui_canvas_layer:
		call_deferred("_reparent_to_ui")

func _reparent_to_ui() -> void:
	reparent(_ui_canvas_layer, true)
	reset_physics_interpolation()



func _collected() -> void:
	Event.ectoplasm_collected(ectoplasm_value)
	_curent_animation_state = AnimationState.COLLECTED
	Event.play_sfx( Enums.SfxTrack.ECTOPLASM_PICKUP )
	queue_free()
