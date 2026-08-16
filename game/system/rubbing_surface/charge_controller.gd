class_name ChargeController
extends Node


enum ChargeStatus {
	NO_CHARGE,
	LOW,
	CHARGED,
	OVERCHARGED
}


@export_category("Configuration")
@export var config: ChargeConfig


var max_charge: float = 200.0
var charge_generation_rate: float = 10.0
var charge_discharge_rate: float = 5.0

var low_charge_threshold: float = 0.20
var charged_threshold: float = 0.50
var overcharged_threshold: float = 1.00

var charge: float = 0.0
var charge_generation: float = 0.0


func _ready() -> void:
	if config:
		apply_config(config)


func apply_config(new_config: ChargeConfig) -> void:
	config = new_config

	max_charge = new_config.max_charge
	charge_generation_rate = new_config.charge_generation_rate
	charge_discharge_rate = new_config.charge_discharge_rate

	low_charge_threshold = new_config.low_charge_threshold
	charged_threshold = new_config.charged_threshold
	overcharged_threshold = new_config.overcharged_threshold

	charge = clamp(charge, 0.0, max_charge)


func update(delta: float, rubbing_intensity: float) -> void:
	charge_generation = (
		rubbing_intensity * charge_generation_rate
	)

	charge += charge_generation * delta
	charge -= charge_discharge_rate * delta

	charge = clamp(charge, 0.0, max_charge)


func get_charge() -> float:
	return charge


func get_charge_ratio() -> float:
	if max_charge <= 0.0:
		return 0.0

	return charge / max_charge


func get_charge_percentage() -> float:
	return get_charge_ratio() * 100.0


func get_charge_rate() -> float:
	return charge_generation - charge_discharge_rate


func get_status() -> ChargeStatus:
	var ratio := get_charge_ratio()

	if ratio < low_charge_threshold:
		return ChargeStatus.NO_CHARGE

	if ratio < charged_threshold:
		return ChargeStatus.LOW

	if ratio < overcharged_threshold:
		return ChargeStatus.CHARGED

	return ChargeStatus.OVERCHARGED


func get_status_name() -> String:
	return ChargeStatus.keys()[get_status()]


func set_max_charge(value: float) -> void:
	max_charge = max(value, 0.0)
	charge = min(charge, max_charge)


func set_charge_generation_rate(value: float) -> void:
	charge_generation_rate = max(value, 0.0)


func set_charge_discharge_rate(value: float) -> void:
	charge_discharge_rate = max(value, 0.0)
