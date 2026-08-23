extends Node

const BASE_SCALING := 500
const UPGRADE_SCALING_FACTOR := 250
const TowerPurchaseButtonScene := preload("res://game/system/ui/tower_purchase/tower_purchase_button.tscn")
const ECTOPLASM_MULTIPLIER_SCALING := 0.25

@export var _starting_ectoplasm: int = 200
@export var _starting_core_charges: int
@onready var level: Level = %Level

var ectoplasm_multiplier := 1.0


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

var _income_upgrade_cost: int:
	set(value):
		_income_upgrade_cost = value
		upgrade_income_button.text = "Upgrade\nIncome\n\n%s" % _income_upgrade_cost
var _tower_upgrade_cost: int:
	set(value):
		_tower_upgrade_cost = value
		_upgrade_tower_button.text = "Upgrade\nTowers\n\n%s" % _tower_upgrade_cost
var _tower_upgrades_purchased := 0:
	set(value):
		_tower_upgrades_purchased = value
		_update_tower_upgrade_cost()
var _income_upgrades_purchased := 0:
	set(value):
		_income_upgrades_purchased = value
		_update_income_upgrade_cost()

@onready var _pause_menu_controller: Node = %PauseMenuController
@onready var _win_lose_manager: Node = %WinLoseManager
@onready var _level : Level = %Level
@onready var _wave_manager: WaveManager = %WaveManager

@onready var _ectoplasm_label: Label = %EctoplasmLabel
@onready var core_charges_count: Label = %CoreChargesCount
@onready var _upgrade_tower_button: Button = %UpgradeTowerButton
@onready var tower_button_container: GridContainer = %TowerButtonContainer
@onready var upgrade_income_button: Button = %UpgradeIncomeButton

@export var tower_resources: Array[TowerResource]

@export var speed_buttons: Array[Button]

@onready var confirmation_popup: TowerConfirmationPopup = \
	$UILayer/UI/TowerConfirmationPopup


func _ready() -> void:
	_connect_speed_buttons()
	_ectoplasm = _starting_ectoplasm
	_core_charges = _starting_core_charges
	Event.ectoplasm_collected_signal.connect(_on_ectoplasm_collected_signal)
	Event.reset_engine_speed_signal.connect(_reset_speed_buttons)
	Event.all_ghosts_in_scene_are_cleared_signal.connect(_check_if_game_won)

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
	_update_income_upgrade_cost()
	_build_tower_buttons()
	_upgrade_tower_button.tooltip_text = "Levels up all built towers\n increasing their efficiency\n (Range, Power and Firing Rate)."
	upgrade_income_button.tooltip_text = "Increases ectoplasm generation"

func _process(_delta: float) -> void:
	update_tower_buttons()
	update_tower_upgrade_button()
	update_income_update_button()


func _connect_speed_buttons()->void:
	_reset_speed_buttons()
	for button in speed_buttons:
		button.pressed.connect( _on_speed_button_pressed.bind(button))


func _on_speed_button_pressed(button: Button) -> void:

	var button_index := speed_buttons.find(button)
	Engine.time_scale = button_index + 1.0 # Array index + 1.0 determines engine speed
	
	for speed_button: Button in speed_buttons:
		speed_button.button_pressed = speed_button == button

func _reset_speed_buttons() -> void:
	speed_buttons[0].button_pressed = true
	Engine.time_scale = 1.0
	for i in range(1, speed_buttons.size()):
		speed_buttons[i].button_pressed = false

func _on_tower_button_pressed(button: TowerPurchaseButton) -> void:
	var preselected_tower: TowerResource = button.tower_resource
	if _ectoplasm >= preselected_tower.purchase_price :
		_level._start_building_placement(preselected_tower)
		ectoplasm_cost = preselected_tower.purchase_price



func _on_ectoplasm_collected_signal(ectoplasm_value: int)->void:
	_ectoplasm += ectoplasm_value * ectoplasm_multiplier

func _on_level_core_damaged(damage:int) -> void:
	_core_charges = max(0,_core_charges-damage)

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
	Event.play_sfx( Enums.SfxTrack.TOWER_PLACEMENT )
	
func _on_confirmation_cancelled() -> void:
	_level.tower_placement_controller.cancel_confirmation()


func _on_upgrade_income_button_pressed() -> void:
	if _ectoplasm < _tower_upgrade_cost:
		return
		
	_ectoplasm -= _income_upgrade_cost
	ectoplasm_multiplier += ECTOPLASM_MULTIPLIER_SCALING
	_income_upgrades_purchased += 1
	Event.play_sfx( Enums.SfxTrack.TOWER_UPGRADE )

func _on_upgrade_tower_button_pressed() -> void:
	
	
	if _ectoplasm < _tower_upgrade_cost:
		return
	
	_ectoplasm -= _tower_upgrade_cost
	var towers: Array[Node] = get_tree().get_nodes_in_group(&"Towers")
	for tower in towers:
		if tower is Tower:
			tower.level_up()
	_tower_upgrades_purchased += 1
	Event.play_sfx( Enums.SfxTrack.TOWER_UPGRADE )


func _update_tower_upgrade_cost() -> void:
	_tower_upgrade_cost = _tower_upgrade_cost + BASE_SCALING + UPGRADE_SCALING_FACTOR * _tower_upgrades_purchased


func _update_income_upgrade_cost() -> void:
	_income_upgrade_cost = BASE_SCALING + UPGRADE_SCALING_FACTOR * _income_upgrades_purchased


func update_tower_upgrade_button() -> void:
	if _ectoplasm < _tower_upgrade_cost:
		_upgrade_tower_button.disabled = true
	else:
		_upgrade_tower_button.disabled = false


func update_income_update_button() -> void:
	if _ectoplasm < _income_upgrade_cost:
		upgrade_income_button.disabled = true
	else:
		upgrade_income_button.disabled = false

func _build_tower_buttons() -> void:
	for tower_resource: TowerResource in tower_resources:
		var tower_button: TowerPurchaseButton = TowerPurchaseButtonScene.instantiate()
		tower_button.set_texture(tower_resource.preview_texture)
		tower_button_container.add_child(tower_button)
		tower_button.pressed.connect(_on_tower_button_pressed.bind(tower_button))
		tower_button.tower_resource = tower_resource

func update_tower_buttons():
	for button : TowerPurchaseButton in tower_button_container.get_children():
		var t_resource = button.tower_resource
		if t_resource.purchase_price <= _ectoplasm:
			button.toggle_enable(true)
		else:
			button.toggle_enable(false)


func _on_wave_manager_generate_wave_rewards(ectoplasm: int) -> void:
	if (ectoplasm > 0):
		# Potentially here we need to add a visual effect to imply this gain.
		_ectoplasm+= ectoplasm * ectoplasm_multiplier
	pass # Replace with function body.


func _check_if_game_won()->void:
	if level.get_number_of_waves() <= _wave_manager.get_current_wave():
		_win_lose_manager.game_won()
