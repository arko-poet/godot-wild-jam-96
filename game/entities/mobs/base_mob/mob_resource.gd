class_name MobResource
extends Resource

enum Charge { NEUTURAL, NEGATIVE, POSITIVE }

@export_category("Visuals")
@export var mob_sprite: SpriteFrames

@export_category("Parameters")
@export var speed : float =100.0
@export var health : float = 20.0
@export var loot: int = 1
@export var damage: int = 1
@export var current_charge: Charge 

@export_category("Grouping")
@export var groups : Array[String] = ["Mobs"]
