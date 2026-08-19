class_name WaveManager extends Node

signal wave_limit_exceeded

@onready var _wave_label: Label = %WaveLabel
var _current_wave: int = 0
var _active_wave: bool = false

@onready var start_wave_button: Button = $"../UILayer/UI/StartWaveButton"
@onready var level: Level = %Level

func _ready() -> void:
	_wave_label.text =  "%s/100" % _current_wave
	start_wave_button.pressed.connect(_on_start_wave_button)
	Event.wave_ended_signal.connect(_on_wave_ended_signal)


func _on_start_wave_button()->void:
	if _active_wave == false:
		_active_wave = true
		_next_wave()

func _on_wave_ended_signal()->void:
	_active_wave = false


func _next_wave()->void:
	_current_wave += 1
	_wave_label.text =  "%s/100" % _current_wave
	Event.next_wave_trigered(_current_wave)


func trigger_next_wave()->void:
	_next_wave()
