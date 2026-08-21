class_name TowerResource
extends Resource

@export_category("Identity")
@export var display_name: String = "Title"

@export_category("Visuals")
@export var tower_sprite: Texture2D
@export var barrel_sprite: Texture2D
@export var preview_texture: Texture2D
@export var perception_radius: float = 64.0
@export var vfx_origin: Vector2 = Vector2.ZERO
@export var modulate_color := Color.WHITE
@export var use_different_modulate_for_barrel: bool = false
@export var barrel_modulate_color: Color = Color.WHITE

@export_category("Activation")
@export var charge_rate: float = 1.0
@export var activation_cost: float = 1.0
@export var power: float = 1.0

@export_category("Economy")
@export var purchase_price: int = 100
@export var sell_price: int = 50

@export_category("Ability")
@export var special_ability: TowerAbility

@export_category("Targeting")
@export var targeting_priority: TargetingPriority.Type = TargetingPriority.Type.FURTHEST_ALONG_PATH
@export var target_group: String = "Mobs"

@export_category("Shape")
## which tiles is the tower going to occupy, use negatives for proper centering
@export var footprint: Array[Vector2i] = [
	Vector2i.ZERO,
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(1, 1),
]

@export_category("Supercharge")
@export var supercharge_charge_rate_multiplier: float = 2.0
@export var supercharge_power_multiplier: float = 1.0
@export var supercharge_range_multipler: float = 1.0
@export var overdrive_cooldown: float = 5.0
@export var charging_configuration: ChargeConfig

@export_category("Scaling")
@export var upgrade_path: Array[TowerUpgradeResource] = []

@export_multiline() var description: String = "Lorem ipsum mikalasur pantur matruym..."
