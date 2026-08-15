extends CharacterBody2D

@export var speed: float = 200.0
@export var health: float = 100.0

var path_progress: float = 0.0


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * speed
	move_and_slide()

	path_progress += velocity.length() * delta

func take_damage(amount: float) -> void:
	health -= amount
	print("Mob took ", amount, " damage. HP: ", health)

	if health <= 0:
		queue_free()
