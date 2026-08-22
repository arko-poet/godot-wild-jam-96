class_name TowerPurchaseButton extends TextureButton

@onready var _cost_label: Label = %CostLabel
@onready var selection_border : Panel = $SelectionBorder
@onready var disabled_visual : TextureRect = $DisabledVisual

const TOOLTIP_SCENE := preload("res://game/system/ui/tower_purchase/tower_menu_tooltip.tscn")


var tower_resource: TowerResource:
	set(value):
		tower_resource = value
		if tower_resource != null:
			_cost_label.text = str(tower_resource.purchase_price)
			self_modulate = tower_resource.modulate_color

func set_texture(texture: Texture2D) -> void:
	texture_normal = texture
	texture_pressed = texture
	texture_hover = texture
	texture_disabled = texture
	texture_focused = texture


func _on_mouse_entered() -> void:
	selection_border.visible = true


func _on_mouse_exited() -> void:
	selection_border.visible = false

func _on_pressed() -> void:
	if not disabled:
		var stylebox := selection_border.get_theme_stylebox("panel") as StyleBoxFlat
		
		var tween := create_tween()
		tween.tween_property(stylebox, "border_color", Color.WHITE, 0.15)
		tween.tween_property(stylebox, "border_color", Color.BLACK, 0.3)
		tween.tween_callback(selection_border.hide)

func toggle_enable(enable: bool) -> void:
	disabled = not enable
	if disabled:
		# disabled_visual.visible = true
		_cost_label.modulate = Color.RED
	else:
		disabled_visual.visible = false
		_cost_label.modulate = Color.WHITE

func _make_custom_tooltip(for_text: String) -> Object:
	var tooltip := TOOLTIP_SCENE.instantiate() as TowerMenuTooltip
	var tower_name = tower_resource.display_name
	var tower_description = tower_resource.description
	tooltip.setup(tower_name, tower_description)

	return tooltip
