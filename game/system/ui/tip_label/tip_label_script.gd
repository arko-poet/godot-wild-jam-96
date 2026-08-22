extends Label


func _ready() -> void:
	Event.tips_toogled_signal.connect(_on_tip_toogle)


func _on_tip_toogle( is_toogled: bool )->void:
	set_visible(is_toogled)
