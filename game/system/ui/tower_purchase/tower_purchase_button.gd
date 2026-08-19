class_name TowerPurchaseButton extends Button

@onready var _cost_label: Label = %CostLabel

var tower_resource: TowerResource:
	set(value):
		print(value)
		tower_resource = value
		if tower_resource != null:
			print(tower_resource.purchase_price)
			_cost_label.text = str(tower_resource.purchase_price)
