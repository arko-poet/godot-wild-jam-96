class_name ChargeParticleEffect extends CPUParticles2D


const MINUS_PARTICLE = preload("uid://01iad3ghlhkt")
const PLUS_PARTICLE = preload("uid://bvott06kehk71")

func _ready() -> void:
	local_coords = true


func display_charge_effect(is_positive: bool) -> void:
	if is_positive:
		texture = PLUS_PARTICLE
	else:
		texture = MINUS_PARTICLE
