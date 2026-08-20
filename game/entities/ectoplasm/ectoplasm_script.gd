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
@export var collect_speed: float = 100.0

## This is here so I can reparent the sprite to canvis layer for visuals when moving towards lable. 
var _ect_lable_ref: Control

func _ready() -> void:
	randomize()
	mouse_detection.area_entered.connect(_on_area_entered)
	
	var ectoplasm_label = get_tree().get_first_node_in_group("ectoplasm_lable")
	_ect_lable_ref = ectoplasm_label
	if ectoplasm_label:
		ectoplasm_ui_location = ectoplasm_label.global_position
	else:
		print("ERROR: Could not find node in group 'ectoplasm_lable'")



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
				collect_speed * delta
			)

			if global_position.distance_to(mouse_collector.global_position) < 2.0:
				current_collecting_state = CollectingState.UI



		CollectingState.UI:
			
			animated_sprite_2d.reparent(_ect_lable_ref, true)
			reset_physics_interpolation()
			global_position = global_position.move_toward(
				ectoplasm_ui_location,
				collect_speed * delta
			)

			if global_position.distance_to(ectoplasm_ui_location) < 2.0:
				_collected()


	



func _play_idle()->void:
	animation_player.play("IDLE")

func _collected() -> void:
	Event.ectoplasm_collected(ectoplasm_value)
	queue_free()
