class_name TowerUpgradeResource
extends Resource

# All these variables represent differences from the previous level. They are
# meant to be used additively to the stats of the tower, not replace them.

@export_category("Tower Stats")
@export var power : float = 0 # For ability power scaling
@export var range : float = 0  # For Range improvements
@export var charge_rate : float = 0 # Ability activation rate improvements

@export_category("Supercharge Stats")
@export var supercharge_charge_rate_multiplier : float = 0.0 # Ability Activation rate Multipler during supercharge
@export var supercharge_power_multiplier : float = 0.0 # Power multiplier modification during supercharge
@export var supercharge_range_multipler : float = 0.0 # Range multiplier modification during supercharge
@export var overdrive_cooldown : float  = 0.0 # To modify the time the tower stays disabled after supercharge

@export_category("Charging Up Stats")
@export var charge_generation_rate: float = 0.0 # Makes charging up faster, or charging down faster when switching charge_type.
@export var charge_discharge_rate: float = 0.0 # Makes losing charge slower, as a consequence also makes charging up faster.

@export_category("Cool Stuff")
@export var ability_replacement : TowerAbility # In case we ever consider to have the Abilities themselves be replaced on upgrades.
