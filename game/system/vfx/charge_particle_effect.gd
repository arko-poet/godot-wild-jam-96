class_name ChargeParticleEffect extends CPUParticles2D


const MINUS_PARTICLE = preload("res://game/assets/vfx/minus_particle.png")
const PLUS_PARTICLE = preload("res://game/assets/vfx/plus_particle.png")

func _ready() -> void:
	local_coords = true


func display_charge_effect(is_positive: bool) -> void:
	if is_positive:
		texture = PLUS_PARTICLE
	else:
		texture = MINUS_PARTICLE


func display_charge_effect_for_tower(is_positive: bool, charge: float) -> void:
	charge = abs(charge)

	if charge == 0.0:
		stop_particle()
		return

	texture = PLUS_PARTICLE if is_positive else MINUS_PARTICLE

	if charge <= 25.0:
		amount = 3
	elif charge <= 50.0:
		amount = 4
	elif charge <= 75.0:
		amount = 5
	else:
		amount = 6

	start_particle()

func stop_particle()->void:
	emitting = false

func start_particle()->void:
	emitting = true
