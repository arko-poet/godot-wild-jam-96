extends Node

@export var _starting_ectoplasm: int
@export var _starting_core_charges: int
@onready var level: Level = %Level


var _ectoplasm: int:
	set(value):
		_ectoplasm = value
		_ectoplasm_label.text = str(_ectoplasm)

var _core_charges: int:
	set(value):
		_core_charges = max(value, 0)
		core_charges_count.text = "100/%s" % _core_charges
		
		if _core_charges == 0:
			_win_lose_manager.game_lost()

@onready var _pause_menu_controller: Node = %PauseMenuController
@onready var _win_lose_manager: Node = %WinLoseManager
@onready var _level : Level = %Level
@onready var _ui : Control = $UILayer/UI
@onready var _ectoplasm_label: Label = %EctoplasmLabel
@onready var core_charges_count: Label = %CoreChargesCount



# Currently all buttons have the attack tower resource untill all 7 towers are created. 
@export var tower_buttons: Dictionary[ Button, TowerResource ]

@export var speed_buttons: Array[Button]

@onready var confirmation_popup: TowerConfirmationPopup = \
	$UILayer/UI/TowerConfirmationPopup


func _ready() -> void:
	_connect_tower_buttons()
	_connect_speed_buttons()
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


func _connect_speed_buttons()->void:
	for button in speed_buttons:
		button.pressed.connect( _on_speed_button_pressed.bind(button))

func _connect_tower_buttons() -> void:
	for button in tower_buttons.keys():
		button.pressed.connect(_on_tower_button_pressed.bind(button))


func _on_speed_button_pressed(button: Button) -> void:
	var button_index := speed_buttons.find(button)
	Engine.time_scale = button_index + 1.0 # Array index + 1.0 to determin engine speed 

func _on_tower_button_pressed(button: Button) -> void:
	var preselected_tower: TowerResource = tower_buttons.get(button)
	if _ectoplasm >= preselected_tower.purchase_price :
		_level._start_building_placement(preselected_tower)
		ectoplasm_cost = preselected_tower.purchase_price



func _on_ectoplasm_collected_signal()->void:
	_ectoplasm += 1

func _on_level_core_damaged() -> void:
	# TODO this should use mob damage instead
	_core_charges -= 1

var ectoplasm_cost = 0

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
