extends Node

@export var _starting_ectoplasm: int
@export var _starting_core_charges: int
@onready var level: Level = %Level


var _ectoplasm: int:
	set(value):
		_ectoplasm = value
		_ectoplasm_label.text = "Ectoplasm: %s" % _ectoplasm
var _core_charges: int:
	set(value):
		_core_charges = max(value, 0)
		_core_charges_label.text = "Core Charges: %s" % _core_charges
		
		if _core_charges == 0:
			_win_lose_manager.game_lost()

@onready var _pause_menu_controller: Node = %PauseMenuController
@onready var _win_lose_manager: Node = %WinLoseManager

@onready var _core_charges_label: Label = %CoreChargesLabel
@onready var _ectoplasm_label: Label = %EctoplasmLabel



func _ready() -> void:
	_ectoplasm = _starting_ectoplasm
	_core_charges = _starting_core_charges


func _on_level_core_damaged() -> void:
	# TODO this should use mob damage instead
	_core_charges -= 1


func _on_place_tower_button_pressed() -> void:
	# TODO handle tower placement, ectoplasm spending
	pass # Replace with function body.


func _on_pause_button_pressed() -> void:
	_pause_menu_controller.pause()
