extends Node

const UPGRADE_SCALING_FACTOR := 1000
const TowerPurchaseButtonScene := preload("res://game/system/ui/tower_purchase/tower_purchase_button.tscn")

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
		core_charges_count.text = "%s/%s" % [_core_charges, _starting_core_charges]
		
		if _core_charges == 0:
			_win_lose_manager.game_lost()

var _tower_upgrade_cost: int:
	set(value):
		_tower_upgrade_cost = value
		_upgrade_tower_button.text = "Upgrade\nTowers\n\n%s" % _tower_upgrade_cost
var _tower_upgrades_purchased := 0:
	set(value):
		_tower_upgrades_purchased = value
		_update_tower_upgrade_cost()

@onready var _pause_menu_controller: Node = %PauseMenuController
@onready var _win_lose_manager: Node = %WinLoseManager
@onready var _level : Level = %Level

@onready var _ui : Control = $UILayer/UI
@onready var _ectoplasm_label: Label = %EctoplasmLabel
@onready var core_charges_count: Label = %CoreChargesCount
@onready var _upgrade_tower_button: Button = %UpgradeTowerButton
@onready var tower_button_container: VBoxContainer = %TowerButtonContainer

@export var tower_resources: Array[TowerResource]

@export var speed_buttons: Array[Button]

@onready var confirmation_popup: TowerConfirmationPopup = \
	$UILayer/UI/TowerConfirmationPopup


func _ready() -> void:
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
	
	_update_tower_upgrade_cost()
	_build_tower_buttons()


func _connect_speed_buttons()->void:
	for button in speed_buttons:
		button.pressed.connect( _on_speed_button_pressed.bind(button))


func _on_speed_button_pressed(button: Button) -> void:
	var button_index := speed_buttons.find(button)
	Engine.time_scale = button_index + 1.0 # Array index + 1.0 to determin engine speed 

func _on_tower_button_pressed(button: TowerPurchaseButton) -> void:
	var preselected_tower: TowerResource = button.tower_resource
	if _ectoplasm >= preselected_tower.purchase_price :
		_level._start_building_placement(preselected_tower)
		ectoplasm_cost = preselected_tower.purchase_price



func _on_ectoplasm_collected_signal(ectoplasm_value: int)->void:
	_ectoplasm += ectoplasm_value

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


func _on_wave_manager_wave_limit_exceeded() -> void:
	_win_lose_manager.game_won()


func _on_upgrade_tower_button_pressed() -> void:
	
	
	if _ectoplasm < _tower_upgrade_cost:
		return
	
	_ectoplasm -= _tower_upgrade_cost
	var towers: Array[Node] = get_tree().get_nodes_in_group(&"Towers")
	for tower in towers:
		if tower is Tower:
			tower.level_up()
	_tower_upgrades_purchased += 1


func _update_tower_upgrade_cost() -> void:
	_tower_upgrade_cost = UPGRADE_SCALING_FACTOR * (1 + _tower_upgrades_purchased)

func _build_tower_buttons() -> void:
	for tower_resource: TowerResource in tower_resources:
		var tower_button: TowerPurchaseButton = TowerPurchaseButtonScene.instantiate()
		tower_button_container.add_child(tower_button)
		tower_button.pressed.connect(_on_tower_button_pressed.bind(tower_button))
		tower_button.icon = tower_resource.tower_sprite
		tower_button.modulate = tower_resource.modulate_color
		tower_button.tower_resource = tower_resource
		
