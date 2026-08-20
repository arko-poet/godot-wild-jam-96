class_name Ectoplasm
extends Node2D


@onready var mouse_detection: Area2D = %MouseDetection
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var ectoplasm_value: int = 1
var mouse_collector: EctoplasmMouseCollector
var is_collecting := false

@export var collect_speed: float = 100.0


func _ready() -> void:
	randomize()
	mouse_detection.area_entered.connect(_on_area_entered)



func _on_area_entered(area: Area2D) -> void:
	if area is EctoplasmMouseCollector:
		mouse_collector = area
		is_collecting = true
		
		animation_player.play("COLLECT")


func _process(delta: float) -> void:
	if not is_collecting:
		return
	
	global_position = global_position.move_toward(
		mouse_collector.global_position,
		collect_speed * delta
	)
	

func _play_idle()->void:
	animation_player.play("IDLE")

func _collected() -> void:
	Event.ectoplasm_collected(ectoplasm_value)
	queue_free()
