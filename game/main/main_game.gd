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
@onready var _level : Level = %Level
@onready var _ui : Control = $UILayer/UI
@onready var _core_charges_label: Label = %CoreChargesLabel
@onready var _ectoplasm_label: Label = %EctoplasmLabel


@onready var confirmation_popup: TowerConfirmationPopup = \
	$UILayer/UI/TowerConfirmationPopup


func _ready() -> void:
	_ectoplasm = _starting_ectoplasm
	_core_charges = _starting_core_charges
	Event.ectoplasm_collected_signal.connect(_on_ectoplasm_collected_signal)

	_level.tower_placement_controller.confirmation_requested.connect(
		_on_tower_placement_confirmation_requested
	)
	confirmation_popup.confirmed.connect(
		_on_confirmation_confirmed
	)

	confirmation_popup.cancelled.connect(
		_on_confirmation_cancelled
	)

func _on_ectoplasm_collected_signal()->void:
	_ectoplasm += 1

func _on_level_core_damaged() -> void:
	# TODO this should use mob damage instead
	_core_charges -= 1

var ectoplasm_cost = 0
func _on_place_tower_button_pressed() -> void:
	# TODO handle tower placement, ectoplasm spending
	var preselected_tower = load("res://game/resources/towers/attack_tower.tres") as TowerResource
	if _ectoplasm >= preselected_tower.purchase_price :
		_level._start_building_placement(preselected_tower)
		ectoplasm_cost = preselected_tower.purchase_price
	pass # Replace with function body.


func _on_pause_button_pressed() -> void:
	_pause_menu_controller.pause()

func _on_tower_placement_confirmation_requested(
	tower: TowerResource
) -> void:
	confirmation_popup.show_for_tower(tower)

func _on_confirmation_confirmed() -> void:
	_level.tower_placement_controller.confirm_placement()
	_ectoplasm = max(0, _ectoplasm - ectoplasm_cost)
	
func _on_confirmation_cancelled() -> void:
	_level.tower_placement_controller.cancel_confirmation()
