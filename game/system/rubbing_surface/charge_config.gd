class_name ChargeConfig
extends Resource


@export_category("Charge")
@export var max_charge: float = 100.0
@export var charge_generation_rate: float = 70.0
@export var charge_discharge_rate: float = 20.0


@export_category("Charge Status Thresholds")
@export_range(0.0, 1.0, 0.01)
var charged_threshold: float = 0.10

@export_range(0.0, 1.0, 0.01)
var overcharged_threshold: float = 1.0
