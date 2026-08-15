extends Node2D


@onready var enemy_details : RichTextLabel = $UI/CenterContainer/HBoxContainer/Panel/VBoxContainer/EnemyDetails
@onready var tower_details : RichTextLabel = $UI/CenterContainer/HBoxContainer/Panel2/VBoxContainer/TowerDetails

@onready var enemy = $MobExample
@onready var tower: Tower = $Tower


func _process(_delta: float) -> void:
	update_enemy_details()
	update_tower_details()


func update_enemy_details() -> void:
	if enemy == null: 
		return
	enemy_details.text = """
	[b]ENEMY[/b]

	Health: %.1f
	Speed: %.1f
	Position: %s
	Path Progress: %.1f
	In Tower Range: %s
	""" % [
		enemy.health,
		enemy.speed,
		str(enemy.global_position),
		enemy.path_progress,
		tower.enemies_in_range.any(
			func(contract: EnemyContract) -> bool:
				return contract.mob == enemy
				)
		]


func update_tower_details() -> void:
	tower_details.text = """
	[b]TOWER[/b]

	Power: %.1f
	Charge: %.2f / %.2f
	Charge Rate: %.2f
	Range: %.1f
	Enemies In Range: %d
	Targeting Priority: %s
	Ability: %s
	""" % [
		tower.power,
		tower.current_charges,
		tower.activation_cost,
		tower.charge_rate,
		tower.perception_radius,
		tower.enemies_in_range.size(),
		TargetingPriority.Type.keys()[tower.data.targeting_priority],
		tower.data.special_ability.get_class()
	]
