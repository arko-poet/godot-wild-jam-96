class_name TowerMenuTooltip
extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var description_label : Label = %DescriptionLabel
@onready var rows_container : VBoxContainer = $MarginContainer/RowsContainer
@onready var just_a_gap : Label = $MarginContainer/RowsContainer/JustAGap

var _title
var _description_raw
var _description_text
var other_rows : Array = []

func setup(title: String, description: String) -> void:
	_title = title
	_description_raw = description

func _ready() -> void:
	title_label.text = _title
	parse_description(_description_raw)
	setup_other_rows()

func parse_description(description:String) -> void:
	# Parse description. First split whenever this combination symbols is found ||.
	# Put all the substrings in an array. The first one is just the description text so we assign it
	# For the rest we just add them to other_rows array.
	_description_text = ""
	other_rows.clear()

	var sections := description.split("||")

	if sections.is_empty():
		return

	_description_text = sections[0].strip_edges()
	description_label.text = _description_text
	
	for i in range(1, sections.size()):
		other_rows.append(sections[i].strip_edges())

func setup_other_rows() -> void:
	if (other_rows.size() >0):
		just_a_gap.visible = true
	else:
		just_a_gap.visible = false
	for row in other_rows:
		var label := Label.new()
		label.text = row
		label.add_theme_font_size_override("font_size", 8)

		if row.contains("+"):
			label.modulate = Color.GREEN
		elif row.contains("-"):
			label.modulate = Color.RED
		
		rows_container.add_child(label)
