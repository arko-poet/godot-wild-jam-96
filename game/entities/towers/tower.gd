class_name Tower
extends Node2D

@export var data: TowerResource

@onready var sprite: Sprite2D = $Sprite2D
@onready var perception_area: Area2D = $PerceptionArea
@onready var perception_shape: CollisionShape2D = $PerceptionArea/CollisionShape2D
@onready var vfx_origin: Marker2D = $VFXOrigin
@onready var range_indicator: Node2D = $RangeIndicator
@onready var range_visual: Sprite2D = $RangeIndicator/Visual


var current_charges: float = 0.0

var perception_radius: float
var charge_rate: float
var activation_cost: float
var power: float
var target_group: String

var enemies_in_range: Array[EnemyContract] = []
var enemy_contracts: Dictionary = {}

var preview_mode :bool = true

## This is a temporary variable. Once we figure out whether we want to have the 
## tower range visibilities setup differently, we should change this alongside with
## Part of the implementation (check _ready)
var default_tower_range_visibility = false 

func _ready() -> void:
	if data == null:
		push_error("Tower has no TowerResource assigned.")
		return
	if preview_mode == false:
		add_to_group("Towers")
	initialize_from_resource()
	set_range_indicator_visible(default_tower_range_visibility)
	queue_redraw()

func initialize_from_resource() -> void:
	sprite.texture = data.tower_sprite

	perception_radius = data.perception_radius
	charge_rate = data.charge_rate
	activation_cost = data.activation_cost
	power = data.power
	target_group = data.target_group

	vfx_origin.position = data.vfx_origin

	update_perception_radius()

func update_perception_radius() -> void:
	var circle := perception_shape.shape as CircleShape2D

	if circle == null:
		circle = CircleShape2D.new()
		perception_shape.shape = circle

	circle.radius = perception_radius
	set_range_indicator_range(perception_radius)

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

	charge(delta)

	if can_activate():
		activate()


func charge(delta: float) -> void:
	current_charges += data.charge_rate * delta

	current_charges = min(
		current_charges,
		data.activation_cost
	)


func can_activate() -> bool:
	return current_charges >= data.activation_cost


func activate() -> void:
	if data.special_ability == null:
		return

	var ability := data.special_ability

	var targets := get_targets(
		ability.get_target_count()
	)

	if ability.requires_targets() and targets.is_empty():
		return

	var context := TowerAbilityContext.new(
		get_vfx_origin(),
		data.power,
		targets
	)

	ability.activate(context)

	current_charges -= data.activation_cost


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
