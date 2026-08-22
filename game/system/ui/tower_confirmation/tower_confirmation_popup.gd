class_name TowerConfirmationPopup
extends PanelContainer


signal confirmed
signal cancelled


@onready var tower_name_label: Label = %TowerName
@onready var tower_sprite: TextureRect = %TowerSprite
@onready var cost_label: Label = %Cost
@onready var description_label: Label = %Description
@onready var confirm_button: Button = %ConfirmButton
@onready var cancel_button: Button = %CancelButton


var tower: TowerResource


func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

	hide()
	
func show_for_tower(tower_resource: TowerResource) -> void:
	tower = tower_resource

	tower_name_label.text = tower_resource.display_name
	tower_sprite.texture = tower_resource.preview_texture
	tower_sprite.self_modulate = tower_resource.modulate_color
	cost_label.text = "Costs: %d" % tower_resource.purchase_price
	
	var description_stripped_of_metadata = strip_description_metadata(tower_resource.description)
	description_label.text = description_stripped_of_metadata

	show()

func strip_description_metadata(description: String) -> String:
	var sections := description.split("||")

	if sections.is_empty():
		return ""

	return sections[0].strip_edges()

func _on_confirm_pressed() -> void:
	hide()
	confirmed.emit()


func _on_cancel_pressed() -> void:
	hide()
	cancelled.emit()
	
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		_on_cancel_pressed()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_accept"):
		_on_confirm_pressed()
		get_viewport().set_input_as_handled()
