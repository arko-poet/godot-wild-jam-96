extends CanvasLayer

@onready var level_lost_window: OverlaidWindow = %LevelLostWindow


func _on_level_lost_window_main_menu_pressed() -> void:
	SceneLoader.load_scene(AppConfig.main_menu_scene_path)


func _on_level_lost_window_restart_pressed() -> void:
	SceneLoader.reload_current_scene()
