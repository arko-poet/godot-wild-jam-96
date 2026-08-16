class_name Mob extends CharacterBody2D

signal mob_killed
signal mob_reached_end_of_path
signal remove_from_manager_pool( ref_to_self: Mob )


@onready var mob_animated_sprite: AnimatedSprite2D = %MobAnimatedSprite
@onready var health_bar: ProgressBar = %HealthBar

@export var data: MobResource

# Runtime Stats
var max_health: float = 1.0
var current_health : float = 1.0
var speed : float = 100.0
var loot : int
var damage : int

# Pathfinding Variables
var mob_path: Array[Vector2]
var path_index: int = 0

# Value to use to determin how fast or how much hp a Mob will have. 
var _difficulty: int = 0
@export var health_curve: float = 1.3
@export var speed_curve: float = 1.5

func _ready():
	if data == null:
			add_to_group("Mobs")
			push_error("Mob has no MobResource assigned.")
			return
	
	initialize_from_resource()
	_run_dificulty_curve()
	_update_health_bar()

func _update_health_bar()->void:
	health_bar.set_max(max_health)
	health_bar.set_value(current_health)
	

func _run_dificulty_curve()->void:
	
	# Health dificulty increase
	var health_ratio_gain: float = _difficulty * health_curve
	max_health += health_ratio_gain
	current_health = max_health
	
	
	# Speed Dificutly increase
	var speed_ratio_gain: float = _difficulty * speed_curve * 0.2 * 35
	speed += speed_ratio_gain 
	
	# Loot Dificutly increase
	var loot_ratio_gain: int = _difficulty * 3
	loot += loot_ratio_gain



func initialize_from_resource() -> void:
	# Currently haven't set to grab sprite from the Data yet.
	# set_sprite(data.mob_sprite) # Something like this would be needed.
	# But some changes would be needed for the animated sprite to work on this.
	max_health = data.health
	current_health = max_health
	speed = data.speed
	loot = data.loot
	damage = data.damage
	mob_animated_sprite.set_sprite_frames(data.mob_sprite)
	
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
func _physics_process(delta: float) -> void:
	if path_index >= mob_path.size():
		velocity = Vector2.ZERO
		mob_reaches_end()
		return

	var target: Vector2 = mob_path[path_index]
	var distance := global_position.distance_to(target)

	if distance <= speed * delta:
		global_position = target
		path_index += 1
		velocity = Vector2.ZERO
		return

	var direction := global_position.direction_to(target)
	velocity = direction * speed

	move_and_slide()


### Event Handlers ###
func take_damage(amount:int) -> void:
	current_health -= amount
	if current_health <= 0:
		kill_mob()
	
	_update_health_bar()

func mob_reaches_end()->void:
	mob_reached_end_of_path.emit()
	_mob_die()
	
func kill_mob() ->void:
	mob_killed.emit()
	_mob_die()

func _mob_die()->void:
	remove_from_manager_pool.emit(self)
	queue_free()
