class_name MobBody extends CharacterBody2D

signal hp_reduced_to_zero
signal mob_reached_end_of_path
@onready var data: MobResource

var health : int = 4
@export var speed : float = 100.0
var loot : int
var damage : int


var path: Array[Vector2]
var path_index: int = 0

func _ready():
	if data == null:
			add_to_group("Mobs")
			push_error("Mob has no MobResource assigned.")
			return
		
	initialize_from_resource()

func initialize_from_resource() -> void:
	# Currently haven't set to grab sprite from the Data yet.
	# set_sprite(data.mob_sprite) # Something like this would be needed.
	# But some changes would be needed for the animated sprite to work on this.
	health = data.health
	speed = data.speed
	loot = data.loot
	damage = data.damage
	
	# Add to required groups.
	for target_group in data.groups:
		add_to_group(target_group)

func take_damage(amount:int) -> void:
	health -= amount
	if health <= 0:
		hp_reduced_to_zero.emit()

func _physics_process(_delta: float) -> void:

	if path_index >= path.size():
		velocity = Vector2.ZERO
		mob_reached_end_of_path.emit()
		return

	var target := path[path_index]
	var direction := global_position.direction_to(target)
	velocity = direction * speed
	move_and_slide()


	if global_position.distance_to(target) < 2.0:

		global_position = target
		path_index += 1
