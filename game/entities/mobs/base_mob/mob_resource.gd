class_name MobResource
extends Resource

enum Charge { NEUTURAL, NEGATIVE, POSITIVE }
enum MobType { REGULAR_GHOST, FAST_GHOST, BOSS_GHOST}

@export_category("Visuals")
@export var mob_sprite: SpriteFrames

@export_category("Parameters")
@export var speed : float =100.0
@export var health : float = 20.0
@export var loot: int = 1
@export var damage: int = 1

@export var charge_type: Enums.ChargeType = Enums.ChargeType.NEUTRAL
@export var mob_type: MobType

@export_category("Grouping")
@export var groups : Array[String] = ["Mobs"]
