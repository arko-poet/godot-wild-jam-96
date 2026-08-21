class_name WaveManager extends Node

signal wave_limit_exceeded

@onready var _wave_label: Label = %WaveLabel
var _current_wave: int = 0:
	set(value):
		_current_wave = value
		_wave_label.text =  "%s/%s" % [_current_wave, level.get_number_of_waves()]
		
var _active_wave: bool = false

@onready var start_wave_button: Button = $"../UILayer/UI/StartWaveButton"
@onready var level: Level = %Level

func _ready() -> void:
	_current_wave = _current_wave
	start_wave_button.pressed.connect(_on_start_wave_button)
	Event.wave_ended_signal.connect(_on_wave_ended_signal)


func _on_start_wave_button()->void:
	if _active_wave == false:
		_active_wave = true
		start_wave_button.disabled = true
		_next_wave()

func _on_wave_ended_signal()->void:
	_active_wave = false
	start_wave_button.disabled = false


func _next_wave()->void:
	_current_wave += 1
	
	if _current_wave > level.get_number_of_waves():
		wave_limit_exceeded.emit()
	
	Event.next_wave_trigered(_current_wave)


func trigger_next_wave()->void:
	_next_wave()
