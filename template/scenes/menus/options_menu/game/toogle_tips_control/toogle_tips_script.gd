extends HBoxContainer

@onready var check_button: CheckButton = %CheckButton


func _ready() -> void:
	check_button.toggled.connect(_on_tips_toggled)


func _on_tips_toggled(is_toggled: bool) -> void:
	Event.tips_toogled(is_toggled)
