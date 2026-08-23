class_name Mob extends CharacterBody2D

signal mob_killed
signal mob_reached_end_of_path (damage_to_core :int)
signal remove_from_manager_pool( ref_to_self: Mob )


@onready var mob_animated_sprite: AnimatedSprite2D = %MobAnimatedSprite
@onready var health_bar: ProgressBar = %HealthBar
@onready var charge_particle_effect: ChargeParticleEffect = %ChargeParticleEffect
@onready var ectoplasm_spawner: EctoplasmSpawner = $EctoplasmSpawner

@export var data: MobResource
@export var fast_ghost_color: Color
@export var boss_ghost_color: Color

# Runtime Stats
var max_health: float = 1.0
var current_health : float = 1.0
var speed : float = 100.0
var loot : int
var damage : int

var charge_type : Enums.ChargeType = Enums.ChargeType.NEUTRAL
var mob_type: MobResource.MobType


# Pathfinding Variables
var mob_path: Array[Vector2]
var path_index: int = 0

# Value to use to determin how fast or how much hp a Mob will have. 
var _difficulty: int = 0
@export var health_curve: float = 0.5


func _ready():
	if data == null:
			add_to_group("Mobs")
			push_error("Mob has no MobResource assigned.")
			return
	
	initialize_from_resource()
	_run_dificulty_curve()
	_update_health_bar()
	_modulate_color_by_mob_type()
	_check_charge_for_vfx()

func _check_charge_for_vfx() -> void:

	match charge_type:
		
		Enums.ChargeType.NEGATIVE:
			charge_particle_effect.display_charge_effect(false)

		Enums.ChargeType.POSITIVE:
			charge_particle_effect.display_charge_effect(true)

		Enums.ChargeType.NEUTRAL:
			charge_particle_effect.emitting = false

func _modulate_color_by_mob_type()->void:
	## this is mainly for debuggin / playtesting untill we implement actual sprite changes for ghost types. 
	
	match mob_type:
		
		MobResource.MobType.FAST_GHOST:
			
			mob_animated_sprite.set_modulate( fast_ghost_color ) 
		
		MobResource.MobType.BOSS_GHOST:
			
			mob_animated_sprite.set_modulate( boss_ghost_color )
			ectoplasm_spawner.spawns_move_than_one_ectoplasm = true



func _update_health_bar()->void:
	health_bar.set_max(max_health)
	health_bar.set_value(current_health)
	

func _run_dificulty_curve()->void:
	
	# Health dificulty increase
	var health_ratio_gain: float = pow(1 + floor(_difficulty / 5), 2) * health_curve
	max_health *= health_ratio_gain
	current_health = max_health
	
	
	# Loot Dificutly increase
	#var loot_ratio_gain: int = _difficulty * 3
	#loot += loot_ratio_gain



func initialize_from_resource() -> void:
	# Currently haven't set to grab sprite from the Data yet.
	# set_sprite(data.mob_sprite) # Something like this would be needed.
	# But some changes would be needed for the animated sprite to work on this.
	max_health = data.health
	current_health = max_health
	speed = data.speed
	loot = data.loot
	damage = data.damage
	charge_type = data.charge_type
	mob_animated_sprite.set_sprite_frames(data.mob_sprite)
	mob_type = data.mob_type
	
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
func take_damage(damage:DamagePacket) -> void:
	# Calculate the Damage Taken based on DamagePacket
	var charge_damage_bonus : float = 0
	if (
		(charge_type == Enums.ChargeType.POSITIVE and damage.charge_sign == Enums.ChargeType.NEGATIVE)
		or (charge_type == Enums.ChargeType.NEGATIVE and damage.charge_sign == Enums.ChargeType.POSITIVE)
		):
		# Edit here to change how the Charge applies extra damage.
		# With the current implementation it only applies double damage.
		charge_damage_bonus = damage.amount
	elif (# penalty if charges match
		(charge_type == Enums.ChargeType.POSITIVE and damage.charge_sign == Enums.ChargeType.POSITIVE)
		or (charge_type == Enums.ChargeType.NEGATIVE and damage.charge_sign == Enums.ChargeType.NEGATIVE)
		):
		charge_damage_bonus -= damage.amount / 2.0
		
	var damage_to_inflict = damage.amount + charge_damage_bonus
	
	# Apply Damage
	current_health -= damage_to_inflict
	if current_health <= 0:
		kill_mob()
	
	_update_health_bar()

func mob_reaches_end()->void:
	mob_reached_end_of_path.emit(damage)
	_mob_die()
	
func kill_mob() ->void:
	mob_killed.emit()
	_mob_die()

func _mob_die()->void:
	remove_from_manager_pool.emit(self)
	Event.play_sfx( Enums.SfxTrack.GHOST_DEATH )
	queue_free()
