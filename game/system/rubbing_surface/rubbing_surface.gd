class_name RubbingSurface
extends Area2D

@export_category("Debug Display")
@export var show_debug_labels := true
@export var show_sprite:= false

@onready var sprite : Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var rubbing_detector: RubbingDetector = $RubbingDetector
@onready var charge_controller: ChargeController = $ChargeController

@onready var intensity_label: Label = $MetricLabelsContainer/IntensityLabel
@onready var charge_label: Label = $MetricLabelsContainer/ChargeLabel
@onready var charge_rate_label: Label = $MetricLabelsContainer/ChargeRateLabel
@onready var status_label: Label = $MetricLabelsContainer/StatusLabel

var is_enabled : bool = true

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	sprite.visible = show_sprite

func _input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				rubbing_detector.start_rubbing()



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				rubbing_detector.stop_rubbing()


func _on_mouse_entered() -> void:
	rubbing_detector.set_mouse_inside(true)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		rubbing_detector.start_rubbing()



func _on_mouse_exited() -> void:
	rubbing_detector.set_mouse_inside(false)


func _physics_process(delta: float) -> void:
	
	var charging_sign = 1
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		charging_sign = -1
	var rubbing_intensity = rubbing_detector.rubbing_intensity
	
	# Allows "Disabling" the Rubbing by preventing it from generating Charge.
	if not is_enabled:
		rubbing_intensity = 0
		
	charge_controller.update(
		delta,
		rubbing_intensity,
		charging_sign
	)

	update_debug_labels()

# Getters to act as a public interface for the Rubbing Surface.
func get_charge() -> float:
	return charge_controller.get_charge()


func get_charge_ratio() -> float:
	return charge_controller.get_charge_ratio()


func get_charge_rate() -> float:
	return charge_controller.get_charge_rate()

func get_charge_status() -> ChargeController.ChargeStatus:
	return charge_controller.get_status()

# Created this to help the towers with knowing whether the Charge is Positive, Negative or Neutral.
func get_charge_type() -> Enums.ChargeType:
	var charge_status = get_charge_status()
	match charge_status:
		ChargeController.ChargeStatus.OVERCHARGED_NEGATIVE:
			return Enums.ChargeType.NEGATIVE
		ChargeController.ChargeStatus.CHARGED_NEGATIVE:
			return Enums.ChargeType.NEGATIVE
		ChargeController.ChargeStatus.CHARGED_POSITIVE:
			return Enums.ChargeType.POSITIVE
		ChargeController.ChargeStatus.OVERCHARGED_POSITIVE:
			return Enums.ChargeType.POSITIVE
		_ :
			return Enums.ChargeType.NEUTRAL

# Created this to help the towers know when it gets Overcharged!
func is_overcharged() -> bool:
	var charge_status = get_charge_status()
	var overcharged_statuses = [ChargeController.ChargeStatus.OVERCHARGED_POSITIVE, ChargeController.ChargeStatus.OVERCHARGED_NEGATIVE]
	if charge_status in overcharged_statuses:
		return true
	else:
		return false

# Setters that can be used during runtime to "Upgrade" Rubbing Surface component
func set_max_charge(value: float) -> void:
	charge_controller.set_max_charge(value)

func set_charge_generation_rate(value: float) -> void:
	charge_controller.set_charge_generation_rate(value)

func set_charge_discharge_rate(value: float) -> void:
	charge_controller.set_charge_discharge_rate(value)

func increment_charge_generation_rate(value:float) -> void:
	var previous_value = charge_controller.charge_generation_rate
	var new_value = previous_value+value
	charge_controller.set_charge_generation_rate(new_value)

func increment_charge_discharge_rate(value:float) -> void:
	var previous_value = charge_controller.charge_discharge_rate
	var new_value = max(0,previous_value+value)
	charge_controller.set_charge_discharge_rate(new_value)

func apply_charge_config(config: ChargeConfig) -> void:
	charge_controller.apply_config(config)

# Debug Labels
func update_debug_labels() -> void:
	if not show_debug_labels:
		intensity_label.hide()
		charge_label.hide()
		charge_rate_label.hide()
		return

	intensity_label.show()
	charge_label.show()
	charge_rate_label.show()

	var intensity := rubbing_detector.rubbing_intensity
	var charge := charge_controller.charge
	var charge_rate := charge_controller.get_charge_rate()
	var status := charge_controller.get_status_name()

	intensity_label.text = "Intensity: %.2f" % intensity
	charge_label.text = "Charge: %.1f / %.1f" % [
		charge,
		charge_controller.max_charge
	]

	charge_rate_label.text = "Charge Rate: %+.2f /s" % charge_rate

	if charge_rate >= 0.0:
		charge_rate_label.modulate = Color.GREEN
	else:
		charge_rate_label.modulate = Color.RED

	status_label.text = status
