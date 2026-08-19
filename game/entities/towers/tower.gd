class_name Tower
extends Node2D

enum TowerState{
	OK,
	SUPERCHARGED,
	DISABLED
}

@export var data: TowerResource

@onready var sprite: Sprite2D = $Sprite2D
@onready var perception_area: Area2D = $PerceptionArea
@onready var perception_shape: CollisionShape2D = $PerceptionArea/CollisionShape2D
@onready var vfx_origin: Marker2D = $VFXOrigin
@onready var range_indicator: Node2D = $RangeIndicator
@onready var range_visual: Sprite2D = $RangeIndicator/Visual
@onready var rubbing_surface : RubbingSurface = $RubbingSurface
@onready var internal_state_timer : Timer = $InternalStateTimer

var tower_ability : TowerAbility
var level = 1
var current_charges: float = 0.0

var perception_radius: float
var charge_rate: float
var activation_cost: float
var power: float
var target_group: String

var enemies_in_range: Array[EnemyContract] = []
var enemy_contracts: Dictionary = {}

var footprint: Array[Vector2i]

var preview_mode :bool = true

## Super Charge
var supercharge_charge_rate_multiplier : float
var supercharge_power_multiplier : float
var supercharge_range_multiplier: float

const overdrive_time :float = 10.0 # 10 Seconds of supercharge/ overdrive.
var overdrive_cooldown: float # Followed by a Cooldown during which the tower is inactive.
var tower_state : TowerState = TowerState.OK

## Current Multipliers
var charge_rate_multiplier :float = 1.0
var power_multiplier: float =1.0
var range_multipler: float =1.0

## This is a temporary variable. Once we figure out whether we want to have the 
## tower range visibilities setup differently, we should change this alongside with
## Part of the implementation (check _ready)
@export var default_tower_range_visibility = false 

func _ready() -> void:
	if data == null:
		push_error("Tower has no TowerResource assigned.")
		return
	if preview_mode == false:
		add_to_group("Towers")
	
	# Duplicating Texture to prevent Towers from accessing the same Texture2D 
	var texture2d = range_visual.texture as GradientTexture2D
	range_visual.texture = texture2d.duplicate(true)
	
	initialize_from_resource()
	set_range_indicator_visible(default_tower_range_visibility)
	queue_redraw()

func initialize_from_resource() -> void:
	sprite.texture = data.tower_sprite
	tower_ability = data.special_ability
	perception_radius = data.perception_radius
	charge_rate = data.charge_rate
	activation_cost = data.activation_cost
	power = data.power
	target_group = data.target_group

	vfx_origin.position = data.vfx_origin
	
	footprint = data.footprint
	
	sprite.modulate = data.modulate_color
	
	# Initialize Supercharging parameters
	supercharge_charge_rate_multiplier = data.supercharge_charge_rate_multiplier
	supercharge_power_multiplier = data.supercharge_power_multiplier
	supercharge_range_multiplier = data.supercharge_range_multipler
	overdrive_cooldown = data.overdrive_cooldown
	if (data.charging_configuration != null):
		rubbing_surface.apply_charge_config(data.charging_configuration)
	
	update_perception_radius()

func update_perception_radius() -> void:
	var circle := perception_shape.shape as CircleShape2D

	if circle == null:
		circle = CircleShape2D.new()
		perception_shape.shape = circle
	
	var rendered_range = perception_radius*range_multipler
	circle.radius = rendered_range
	set_range_indicator_range(rendered_range)

func upgrade_range(amount: float) -> void:
	perception_radius += amount
	update_perception_radius()

func set_preview_mode(enabled: bool) -> void:
	preview_mode = enabled

func set_preview_color(color: Color) -> void:
	modulate = color
	pass

func _process(delta: float) -> void:
	if data == null or preview_mode == true:
		return
	update_supercharge()
	charge(delta)

	if can_activate():
		activate()


func charge(delta: float) -> void:	
	current_charges += charge_rate * charge_rate_multiplier * delta

	current_charges = min(
		current_charges,
		activation_cost
	)


func can_activate() -> bool:
	return current_charges >= activation_cost


func activate() -> void:
	if tower_ability == null:
		return

	var ability := tower_ability

	var targets := get_targets(
		ability.get_target_count()
	)

	if ability.requires_targets() and targets.is_empty():
		return
	
	var context := TowerAbilityContext.new(
		get_vfx_origin(),
		power*power_multiplier,
		targets,
		rubbing_surface.get_charge_type()
	)

	ability.activate(context)

	current_charges -= activation_cost

func update_supercharge():
	if rubbing_surface.is_overcharged() and tower_state == TowerState.OK:
		# Enter Supercharged State, disable rubbing_surface and start Overdrive Timer.
		tower_state = TowerState.SUPERCHARGED
		rubbing_surface.is_enabled = false
		charge_rate_multiplier = supercharge_charge_rate_multiplier
		power_multiplier = supercharge_power_multiplier
		range_multipler = supercharge_range_multiplier
		
		internal_state_timer.start(overdrive_time)
		update_perception_radius()


func get_vfx_origin() -> Vector2:
	return vfx_origin.global_position


func get_targets(target_count: int) -> Array[EnemyContract]:
	var valid_targets := enemies_in_range.duplicate()

	sort_targets(valid_targets)

	if target_count < 0:
		return valid_targets

	return valid_targets.slice(
		0,
		min(target_count, valid_targets.size())
	)


func sort_targets(targets: Array[EnemyContract]) -> void:
	targets.sort_custom(
		func(a: EnemyContract, b: EnemyContract) -> bool:
			return is_target_higher_priority(a, b)
	)


func is_target_higher_priority(
	a: EnemyContract,
	b: EnemyContract
) -> bool:

	match data.targeting_priority:

		TargetingPriority.Type.FURTHEST_ALONG_PATH:
			return a.path_progress > b.path_progress

		TargetingPriority.Type.CLOSEST_TO_TOWER:
			return global_position.distance_squared_to(a.global_position) < \
				global_position.distance_squared_to(b.global_position)

		TargetingPriority.Type.LOWEST_HP:
			return a.health < b.health

		TargetingPriority.Type.HIGHEST_HP:
			return a.health > b.health

		TargetingPriority.Type.FASTEST:
			return a.speed > b.speed

		TargetingPriority.Type.SLOWEST:
			return a.speed < b.speed

	return false



func _on_perception_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group(target_group):
		return

	if enemy_contracts.has(body):
		return
	var contract := EnemyContract.new(body)

	enemy_contracts[body] = contract
	enemies_in_range.append(contract)


func _on_perception_area_body_exited(body: Node2D) -> void:
	if not enemy_contracts.has(body):
		return

	var contract: EnemyContract = enemy_contracts[body]
	enemy_contracts.erase(body)
	enemies_in_range.erase(contract)


func set_range_indicator_visible(visible: bool) -> void:
	if preview_mode == true:
		# Preventing Potential future controls from interacting weirdly with preview towers.
		range_indicator.visible = true
		return
	range_indicator.visible = visible

func set_range_indicator_range(range: float) -> void:
	var texture := range_visual.texture as GradientTexture2D

	texture.width = int(range * 2.0)
	texture.height = int(range * 2.0)


func _on_internal_state_timer_timeout() -> void:
	if tower_state == TowerState.SUPERCHARGED:
		# Disable Tower for a cooldown.
		tower_state = TowerState.DISABLED
		
		# Also Resetting its attack readiness (current_charges) to 0.
		current_charges = 0
		
		# Getting the charge_rate_multiplier to zero pretty much deactivates the tower.
		charge_rate_multiplier = 0.0
		power_multiplier = 1.0
		range_multipler = 1.0
		
		# Start internal State timer again for the cooldown duration
		internal_state_timer.start(overdrive_cooldown)
		update_perception_radius()
		return
	
	if tower_state == TowerState.DISABLED:
		# Re-enable Tower.
		tower_state = TowerState.OK
		charge_rate_multiplier = 1.0
		rubbing_surface.is_enabled = true
		return

# Leveling Up.
func level_up():
	level += 1
	var scaling_data = TowerUpgradeManager.get_scaling_data(level,data)
	
	# Apply Scaling Data
	if scaling_data != null:
		apply_scaling_data(scaling_data)

func apply_scaling_data(scaling_data: TowerUpgradeResource):
	power += scaling_data.power
	perception_radius += scaling_data.range
	charge_rate += scaling_data.charge_rate
	
	supercharge_charge_rate_multiplier += scaling_data.supercharge_charge_rate_multiplier
	supercharge_power_multiplier += scaling_data.supercharge_power_multiplier
	supercharge_range_multiplier += scaling_data.supercharge_range_multipler
	overdrive_cooldown = max(0,overdrive_cooldown - scaling_data.overdrive_cooldown)
	
	rubbing_surface.increment_charge_generation_rate(scaling_data.charge_generation_rate)
	rubbing_surface.increment_charge_discharge_rate(scaling_data.charge_discharge_rate)
	
	if scaling_data.ability_replacement != null:
		tower_ability = scaling_data.ability_replacement
	update_perception_radius()
