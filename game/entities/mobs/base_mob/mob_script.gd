class_name Mob extends CharacterBody2D

signal mob_killed
signal mob_reached_end_of_path
signal remove_from_manager_pool( ref_to_self: Mob )

@export var data: MobResource

# Runtime Stats
var health : int = 1
@export var speed : float = 100.0
var loot : int
var damage : int

# Pathfinding Variables
var mob_path: Array[Vector2]
var path_index: int = 0

# Value to use to determin how fast or how much hp a Mob will have. 
var _difficulty: int = 0

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

# PATH SETUP
func set_up_path(path: Array[Vector2]) -> void:
	mob_path= path
	path_index = 0
	if path.is_empty():
		push_error("[Mob] Received empty path.")
		return

func set_difficulty( v: int )->void:
	_difficulty = v


### Lifetime Loop ###
func _physics_process(_delta: float) -> void:
	if path_index >= mob_path.size():
		velocity = Vector2.ZERO
		mob_reaches_end()
		return

	var target := mob_path[path_index]
	var direction := global_position.direction_to(target)
	velocity = direction * speed
	move_and_slide()
	
	if global_position.distance_to(target) < 2.0:

		global_position = target
		path_index += 1

### Event Handlers ###
func take_damage(amount:int) -> void:
	health -= amount
	if health <= 0:
		kill_mob()

func mob_reaches_end()->void:
	mob_reached_end_of_path.emit()
	_mob_die()
	
func kill_mob() ->void:
	mob_killed.emit()
	_mob_die()

func _mob_die()->void:
	remove_from_manager_pool.emit(self)
	queue_free()
