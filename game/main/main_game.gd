extends Node

@export var _starting_ectoplasm: int
@export var _starting_core_charges: int

var _wave := 0:
	set(value):
		_wave = value
		_wave_label.text = "Wave: %s" % _wave
var _ectoplasm: int:
	set(value):
		_ectoplasm = value
		_ectoplasm_label.text = "Ectoplasm: %s" % _ectoplasm
var _core_charges: int:
	set(value):
		_core_charges = value
		_core_charges_label.text = "Core Charges: %s" % _core_charges

@onready var _level: Level = %Level

@onready var _core_charges_label: Label = %CoreChargesLabel
@onready var _ectoplasm_label: Label = %EctoplasmLabel
@onready var _wave_label: Label = %WaveLabel

@onready var _pause_menu_controller: Node = %PauseMenuController


func _ready() -> void:
	_ectoplasm = _starting_ectoplasm
	_core_charges = _starting_core_charges


func _on_level_core_damaged() -> void:
	_core_charges -= 1


func _on_place_tower_button_pressed() -> void:
	# TODO handle tower placement, ectoplasm spending
	pass # Replace with function body.


func _on_start_wave_button_pressed() -> void:
	_wave += 1


func _on_pause_button_pressed() -> void:
	_pause_menu_controller.pause()
