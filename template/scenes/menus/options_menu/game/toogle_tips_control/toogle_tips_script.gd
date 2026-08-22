extends HBoxContainer

@onready var check_button: CheckButton = %CheckButton
@export var game_options_resource: GameOptionsResource

func _ready() -> void:
	check_button.toggled.connect(_on_tips_toggled)
	
	check_button.button_pressed = game_options_resource.is_tips_toogle


func _on_tips_toggled(is_toggled: bool) -> void:
	Event.tips_toogled(is_toggled)
	game_options_resource.is_tips_toogled = is_toggled
