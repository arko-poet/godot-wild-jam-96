class_name TowerResource
extends Resource
@export_category("Identity")
@export var display_name: String = "Title"
@export_multiline() var description: String = "Lorem ipsum mikalasur pantur matruym..."

@export_category("Visuals")
@export var tower_sprite: Texture2D
@export var perception_radius: float = 100.0
@export var vfx_origin: Vector2 = Vector2.ZERO

@export_category("Activation")
@export var charge_rate: float = 1.0
@export var activation_cost: float = 100.0
@export var power: float = 1.0

@export_category("Economy")
@export var purchase_price: int = 0
@export var sell_price: int = 0

@export_category("Ability")
@export var special_ability: TowerAbility

@export_category("Targeting")
@export var targeting_priority: TargetingPriority.Type = TargetingPriority.Type.FURTHEST_ALONG_PATH
@export var target_group : String = "Mobs"
