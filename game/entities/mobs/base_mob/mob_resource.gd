class_name MobResource
extends Resource

@export_category("Visuals")
@export var mob_sprite: Texture2D

@export_category("Parameters")
@export var speed : float =100.0
@export var health : int = 20
@export var loot: int = 1
@export var damage: int = 1

@export_category("Grouping")
@export var groups : Array[String] = ["Mobs"]
